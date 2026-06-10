#!/usr/bin/env bash

set -euo pipefail

log() {
    printf '[smoke-stream] %s\n' "$*"
}

die() {
    printf '[smoke-stream] error: %s\n' "$*" >&2
    exit 1
}

ANGIE_BIN="${ANGIE_BIN:-/usr/sbin/angie}"
STREAM_PORT="${1:-18080}"
UPSTREAM_PORT="${2:-18081}"

command -v "${ANGIE_BIN}" >/dev/null 2>&1 || die "missing command: ${ANGIE_BIN}"
command -v python3 >/dev/null 2>&1 || die "missing command: python3"
command -v curl >/dev/null 2>&1 || die "missing command: curl"

log "check=configure-args-stream"
for marker in '--with-stream' '--with-stream_ssl_module' '--with-stream_ssl_preread_module'; do
    if ! "${ANGIE_BIN}" -V 2>&1 | grep -F -- "${marker}" >/dev/null 2>&1; then
        die "angie -V does not contain ${marker}"
    fi
done

temp_root="$(mktemp -d)"
backend_log="${temp_root}/backend.log"
stream_conf="${temp_root}/stream.conf"
backend_pid=''
angie_pid=''

cleanup() {
    if [[ -n "${angie_pid}" ]] && kill -0 "${angie_pid}" >/dev/null 2>&1; then
        kill "${angie_pid}" >/dev/null 2>&1 || true
        wait "${angie_pid}" >/dev/null 2>&1 || true
    fi

    if [[ -n "${backend_pid}" ]] && kill -0 "${backend_pid}" >/dev/null 2>&1; then
        kill "${backend_pid}" >/dev/null 2>&1 || true
        wait "${backend_pid}" >/dev/null 2>&1 || true
    fi

    rm -rf "${temp_root}"
}

trap cleanup EXIT

log "start=backend port=${UPSTREAM_PORT}"
python3 -m http.server "${UPSTREAM_PORT}" --bind 127.0.0.1 >"${backend_log}" 2>&1 &
backend_pid="$!"
sleep 1
kill -0 "${backend_pid}" >/dev/null 2>&1 || die "backend server failed to start"

cat > "${stream_conf}" <<EOF
user angie angie;
include /etc/angie/modules.d/*.conf;

pid ${temp_root}/angie.pid;
error_log stderr notice;

events {}

stream {
    server {
        listen 127.0.0.1:${STREAM_PORT};
        proxy_pass 127.0.0.1:${UPSTREAM_PORT};
    }
}
EOF

log "check=stream-config"
if ! "${ANGIE_BIN}" -t -c "${stream_conf}" >/dev/null 2>&1; then
    die "temporary stream config test failed"
fi

log "start=temporary-angie"
"${ANGIE_BIN}" -c "${stream_conf}" -g 'daemon off;' >"${temp_root}/angie.log" 2>&1 &
angie_pid="$!"
sleep 1
kill -0 "${angie_pid}" >/dev/null 2>&1 || die "temporary angie stream process failed to start"

log "check=stream-proxy request=http://127.0.0.1:${STREAM_PORT}/"
if ! curl --silent --show-error --fail "http://127.0.0.1:${STREAM_PORT}/" >/dev/null; then
    die "stream proxy request failed"
fi

log "result=pass"
