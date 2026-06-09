#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

SOURCE_CACHE_DIR="${REPO_ROOT}/source/downloads"

ensure_source_cache_dir() {
    mkdir -p "${SOURCE_CACHE_DIR}"
}

resolve_source_archive() {
    local filename="${1:?filename is required}"
    local archive_path="${SOURCE_CACHE_DIR}/${filename}"

    log_stage "resolve source archive"
    ensure_source_cache_dir

    if [[ -f "${archive_path}" ]]; then
        log_info "using cached source archive: ${archive_path}"
        printf '%s\n' "${archive_path}"
        return 0
    fi

    die "source archive not found in cache yet: ${archive_path}"
}

fetch_source_from_upstream() {
    local upstream_url="${1:?upstream_url is required}"
    local filename="${2:?filename is required}"

    log_stage "fetch source"
    log_info "upstream_url=${upstream_url}"
    log_info "filename=${filename}"
    die "upstream download is not implemented in the skeleton yet"
}
