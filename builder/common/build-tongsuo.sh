#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

prepare_tongsuo_build() {
    local source_dir="${1:?source_dir is required}"
    local build_root="${2:?build_root is required}"
    local install_root="${3:?install_root is required}"
    local config_args_file="${4:?config_args_file is required}"

    log_stage "prepare tongsuo build"
    log_info "source_dir=${source_dir}"
    log_info "build_root=${build_root}"
    log_info "install_root=${install_root}"

    mkdir -p "${build_root}" "${install_root}"

    cat > "${config_args_file}" <<EOF
enable-ntls
enable-ssl3
shared
--prefix=${install_root}
--libdir=lib
EOF
}
