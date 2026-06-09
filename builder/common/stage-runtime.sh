#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

prepare_staging_tree() {
    local staging_root="${1:?staging_root is required}"

    log_stage "prepare staging tree"

    mkdir -p \
        "${staging_root}${INSTALL_PREFIX}" \
        "${staging_root}${CONF_PREFIX}" \
        "${staging_root}${STATE_DIR}" \
        "${staging_root}${CACHE_DIR}" \
        "${staging_root}${LOG_DIR}" \
        "${staging_root}/usr/lib/systemd/system" \
        "${staging_root}/usr/lib/tmpfiles.d"
}

print_staging_summary() {
    local staging_root="${1:?staging_root is required}"

    log_info "staging_root=${staging_root}"
    print_key_paths
}
