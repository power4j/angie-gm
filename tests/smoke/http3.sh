#!/usr/bin/env bash

set -euo pipefail

log() {
    printf '[smoke-http3] %s\n' "$*"
}

die() {
    printf '[smoke-http3] error: %s\n' "$*" >&2
    exit 1
}

ANGIE_BIN="${ANGIE_BIN:-/usr/sbin/angie}"
HTTP3_PORT="${1:-8443}"

command -v "${ANGIE_BIN}" >/dev/null 2>&1 || die "missing command: ${ANGIE_BIN}"

log "check=configure-args-http3"
if ! "${ANGIE_BIN}" -V 2>&1 | grep -F -- '--with-http_v3_module' >/dev/null 2>&1; then
    die "angie -V does not contain --with-http_v3_module"
fi

temp_conf="$(mktemp)"
trap 'rm -f "${temp_conf}"' EXIT

cat > "${temp_conf}" <<EOF
pid /tmp/angie-http3.pid;
error_log stderr notice;

events {}

http {
    server {
        listen ${HTTP3_PORT} quic reuseport;
        server_name _;
        return 200 "http3-check\n";
    }
}
EOF

log "check=quic-listen-directive port=${HTTP3_PORT}"
if ! "${ANGIE_BIN}" -t -c "${temp_conf}" >/dev/null 2>&1; then
    die "temporary HTTP/3 config test failed"
fi

log "result=pass"
