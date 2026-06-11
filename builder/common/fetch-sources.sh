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
    local archive_path="${SOURCE_CACHE_DIR}/${filename}"
    local temp_path="${archive_path}.part"

    log_stage "fetch source"
    log_info "upstream_url=${upstream_url}"
    log_info "filename=${filename}"

    ensure_source_cache_dir
    rm -f "${temp_path}"

    if command -v curl >/dev/null 2>&1; then
        if ! curl --fail --location --retry 3 --output "${temp_path}" "${upstream_url}"; then
            rm -f "${temp_path}"
            die "failed to download source archive: ${upstream_url}"
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget --output-document="${temp_path}" "${upstream_url}"; then
            rm -f "${temp_path}"
            die "failed to download source archive: ${upstream_url}"
        fi
    else
        die "curl or wget is required to download source archives"
    fi

    [[ -f "${temp_path}" ]] || die "download did not produce archive: ${temp_path}"
    mv "${temp_path}" "${archive_path}"
    log_info "downloaded source archive: ${archive_path}"
    printf '%s\n' "${archive_path}"
}

resolve_or_fetch_source_archive() {
    local upstream_url="${1:?upstream_url is required}"
    local filename="${2:?filename is required}"
    local archive_path="${SOURCE_CACHE_DIR}/${filename}"

    if [[ -f "${archive_path}" ]]; then
        resolve_source_archive "${filename}"
    else
        fetch_source_from_upstream "${upstream_url}" "${filename}"
    fi
}
