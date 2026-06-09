#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

verify_checksum_entry_exists() {
    local checksum_file="${1:?checksum_file is required}"
    local filename="${2:?filename is required}"

    log_stage "verify checksum entry"

    [[ -f "${checksum_file}" ]] || die "checksum file not found: ${checksum_file}"
    grep -F "  ${filename}" "${checksum_file}" >/dev/null || die "checksum entry missing for ${filename}"
}

verify_checksum_file_format() {
    local checksum_file="${1:?checksum_file is required}"

    log_stage "verify checksum file format"

    [[ -s "${checksum_file}" ]] || log_warn "checksum file is empty: ${checksum_file}"
}
