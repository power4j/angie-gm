#!/usr/bin/env bash

set -euo pipefail

URL="${1:-http://127.0.0.1/}"
EXPECTED_TITLE="${EXPECTED_TITLE:-Welcome to Angie}"
EXPECTED_MARKER_ONE="${EXPECTED_MARKER_ONE:-This page confirms that}"
EXPECTED_MARKER_TWO="${EXPECTED_MARKER_TWO:-angie-gm}"
EXPECTED_MARKER_THREE="${EXPECTED_MARKER_THREE:-is installed and running.}"

log() {
    printf '[smoke-http] %s\n' "$*"
}

command -v curl >/dev/null 2>&1 || {
    printf '[smoke-http] error: missing command: curl\n' >&2
    exit 1
}

log "request=${URL}"
response_body="$(curl --fail --silent --show-error "${URL}")"

printf '%s' "${response_body}" | grep -F "${EXPECTED_TITLE}" >/dev/null 2>&1 || {
    printf '[smoke-http] error: response does not contain expected title: %s\n' "${EXPECTED_TITLE}" >&2
    exit 1
}

printf '%s' "${response_body}" | grep -F "${EXPECTED_MARKER_ONE}" >/dev/null 2>&1 || {
    printf '[smoke-http] error: response does not contain expected marker: %s\n' "${EXPECTED_MARKER_ONE}" >&2
    exit 1
}

printf '%s' "${response_body}" | grep -F "${EXPECTED_MARKER_TWO}" >/dev/null 2>&1 || {
    printf '[smoke-http] error: response does not contain expected marker: %s\n' "${EXPECTED_MARKER_TWO}" >&2
    exit 1
}

printf '%s' "${response_body}" | grep -F "${EXPECTED_MARKER_THREE}" >/dev/null 2>&1 || {
    printf '[smoke-http] error: response does not contain expected marker: %s\n' "${EXPECTED_MARKER_THREE}" >&2
    exit 1
}

log "result=pass"
