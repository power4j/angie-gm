#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

prepare_angie_build() {
    local source_dir="${1:?source_dir is required}"
    local build_root="${2:?build_root is required}"
    local configure_args_file="${3:?configure_args_file is required}"

    log_stage "prepare angie build"
    log_info "source_dir=${source_dir}"
    log_info "build_root=${build_root}"
    log_info "configure_args_file=${configure_args_file}"

    mkdir -p "${build_root}"
    [[ -f "${configure_args_file}" ]] || die "configure args file not found: ${configure_args_file}"
}
