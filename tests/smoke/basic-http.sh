#!/usr/bin/env bash

set -euo pipefail

URL="${1:-http://127.0.0.1/}"

log() {
    printf '[smoke-http] %s\n' "$*"
}

command -v curl >/dev/null 2>&1 || {
    printf '[smoke-http] error: missing command: curl\n' >&2
    exit 1
}

log "request=${URL}"
curl --fail --silent --show-error --head "${URL}"
log "result=pass"
