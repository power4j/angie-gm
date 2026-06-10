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
TLS_CERT="${TLS_CERT:-/etc/ssl/certs/ssl-cert-snakeoil.pem}"
TLS_KEY="${TLS_KEY:-/etc/ssl/private/ssl-cert-snakeoil.key}"
TEMP_TLS_DIR=""

discover_tls_paths() {
    local cert_candidate
    local key_candidate

    if [[ -f "${TLS_CERT}" && -f "${TLS_KEY}" ]]; then
        return
    fi

    for cert_candidate in \
        /etc/ssl/certs/ssl-cert-snakeoil.pem \
        /etc/ssl/certs/localhost.crt \
        /etc/pki/tls/certs/localhost.crt \
        /etc/pki/tls/certs/angie-gm-http3.crt
    do
        for key_candidate in \
            /etc/ssl/private/ssl-cert-snakeoil.key \
            /etc/ssl/private/localhost.key \
            /etc/pki/tls/private/localhost.key \
            /etc/pki/tls/private/angie-gm-http3.key
        do
            if [[ -f "${cert_candidate}" && -f "${key_candidate}" ]]; then
                TLS_CERT="${cert_candidate}"
                TLS_KEY="${key_candidate}"
                return
            fi
        done
    done
}

command -v "${ANGIE_BIN}" >/dev/null 2>&1 || die "missing command: ${ANGIE_BIN}"
command -v openssl >/dev/null 2>&1 || die "missing command: openssl"
discover_tls_paths

if [[ ! -f "${TLS_CERT}" || ! -f "${TLS_KEY}" ]]; then
    TEMP_TLS_DIR="$(mktemp -d)"
    TLS_CERT="${TEMP_TLS_DIR}/localhost.crt"
    TLS_KEY="${TEMP_TLS_DIR}/localhost.key"
    openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout "${TLS_KEY}" \
        -out "${TLS_CERT}" \
        -subj "/CN=localhost" \
        -days 1 >/dev/null 2>&1 || die "failed to generate temporary TLS certificate"
fi

log "check=configure-args-http3"
if ! "${ANGIE_BIN}" -V 2>&1 | grep -F -- '--with-http_v3_module' >/dev/null 2>&1; then
    die "angie -V does not contain --with-http_v3_module"
fi

temp_conf="$(mktemp)"
trap 'rm -f "${temp_conf}"; if [[ -n "${TEMP_TLS_DIR}" ]]; then rm -rf "${TEMP_TLS_DIR}"; fi' EXIT

cat > "${temp_conf}" <<EOF
user angie angie;
include /etc/angie/modules.d/*.conf;

pid /tmp/angie-http3.pid;
error_log stderr notice;

events {}

http {
    server {
        listen ${HTTP3_PORT} ssl;
        listen ${HTTP3_PORT} quic reuseport;
        server_name _;
        ssl_certificate ${TLS_CERT};
        ssl_certificate_key ${TLS_KEY};
        return 200 "http3-check\n";
    }
}
EOF

log "check=quic-listen-directive port=${HTTP3_PORT}"
if ! "${ANGIE_BIN}" -t -c "${temp_conf}" >/dev/null 2>&1; then
    die "temporary HTTP/3 config test failed"
fi

log "result=pass"
