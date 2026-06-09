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
shared
threads
--prefix=${install_root}
--openssldir=${install_root}/ssl
--libdir=lib
EOF
}

detect_make_jobs() {
    if command -v nproc >/dev/null 2>&1; then
        nproc
        return
    fi

    if command -v getconf >/dev/null 2>&1; then
        getconf _NPROCESSORS_ONLN
        return
    fi

    printf '1\n'
}

build_tongsuo() {
    local source_dir="${1:?source_dir is required}"
    local build_root="${2:?build_root is required}"
    local install_root="${3:?install_root is required}"
    local config_args_file="${4:?config_args_file is required}"
    local config_script="${source_dir}/config"
    local make_jobs
    local config_args=()
    local configure_log_file="${build_root}/configure.log"
    local make_log_file="${build_root}/make.log"
    local install_log_file="${build_root}/install.log"

    log_stage "build tongsuo"
    log_info "source_dir=${source_dir}"
    log_info "build_root=${build_root}"
    log_info "install_root=${install_root}"
    log_info "config_args_file=${config_args_file}"
    log_info "configure_log_file=${configure_log_file}"
    log_info "make_log_file=${make_log_file}"
    log_info "install_log_file=${install_log_file}"

    [[ -x "${config_script}" ]] || die "tongsuo config script not found or not executable: ${config_script}"
    [[ -f "${config_args_file}" ]] || die "tongsuo config args file not found: ${config_args_file}"

    mapfile -t config_args < "${config_args_file}"
    [[ "${#config_args[@]}" -gt 0 ]] || die "tongsuo config args file is empty: ${config_args_file}"

    rm -rf "${build_root}" "${install_root}"
    mkdir -p "${build_root}" "${install_root}"

    make_jobs="$(detect_make_jobs)"
    log_info "make_jobs=${make_jobs}"
    log_info "configure_command=${config_script} ${config_args[*]}"

    (
        cd "${build_root}"

        if ! "${config_script}" "${config_args[@]}" 2>&1 | tee "${configure_log_file}"; then
            die "tongsuo configure failed; check ${configure_log_file}"
        fi

        if ! make -j "${make_jobs}" 2>&1 | tee "${make_log_file}"; then
            die "tongsuo make failed; check ${make_log_file}"
        fi

        if ! make install_runtime_libs install_dev 2>&1 | tee "${install_log_file}"; then
            die "tongsuo install failed; check ${install_log_file}"
        fi
    )

    [[ -d "${install_root}/include" ]] || die "tongsuo include output not found: ${install_root}/include"
    [[ -d "${install_root}/lib" ]] || die "tongsuo library output not found: ${install_root}/lib"
}
