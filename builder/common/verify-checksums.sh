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

verify_source_archive_checksum() {
    local checksum_file="${1:?checksum_file is required}"
    local archive_path="${2:?archive_path is required}"
    local filename
    local archive_dir

    filename="$(basename "${archive_path}")"
    archive_dir="$(cd "$(dirname "${archive_path}")" && pwd)"

    verify_checksum_entry_exists "${checksum_file}" "${filename}"

    log_stage "verify source archive checksum"
    (
        cd "${archive_dir}"
        grep -F "  ${filename}" "${checksum_file}" | sha256sum --check --
    ) || die "checksum verification failed for ${filename}"
}
