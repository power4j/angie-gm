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

build_angie() {
    local source_dir="${1:?source_dir is required}"
    local build_root="${2:?build_root is required}"
    local configure_args_file="${3:?configure_args_file is required}"
    local staging_root="${4:?staging_root is required}"
    local configure_script="${source_dir}/configure"
    local configure_log_file="${build_root}/configure.log"
    local make_log_file="${build_root}/make.log"
    local install_log_file="${build_root}/install.log"
    local make_jobs
    local configure_args=()

    log_stage "build angie"
    log_info "source_dir=${source_dir}"
    log_info "build_root=${build_root}"
    log_info "configure_args_file=${configure_args_file}"
    log_info "staging_root=${staging_root}"
    log_info "configure_log_file=${configure_log_file}"
    log_info "make_log_file=${make_log_file}"
    log_info "install_log_file=${install_log_file}"

    [[ -x "${configure_script}" ]] || die "angie configure script not found or not executable: ${configure_script}"
    [[ -f "${configure_args_file}" ]] || die "angie configure args file not found: ${configure_args_file}"

    mapfile -t configure_args < "${configure_args_file}"
    [[ "${#configure_args[@]}" -gt 0 ]] || die "angie configure args file is empty: ${configure_args_file}"

    rm -rf "${build_root}"
    mkdir -p "${build_root}" "${staging_root}"

    make_jobs="$(detect_make_jobs)"
    log_info "make_jobs=${make_jobs}"
    log_info "configure_command=${configure_script} ${configure_args[*]}"

    (
        cd "${source_dir}"

        if ! "${configure_script}" --builddir="${build_root}" "${configure_args[@]}" 2>&1 | tee "${configure_log_file}"; then
            die "angie configure failed; check ${configure_log_file}"
        fi

        if ! make -j "${make_jobs}" 2>&1 | tee "${make_log_file}"; then
            die "angie make failed; check ${make_log_file}"
        fi

        if ! make install DESTDIR="${staging_root}" 2>&1 | tee "${install_log_file}"; then
            die "angie install failed; check ${install_log_file}"
        fi
    )

    [[ -x "${staging_root}${INSTALL_PREFIX}/sbin/angie" ]] || die "angie binary not found: ${staging_root}${INSTALL_PREFIX}/sbin/angie"
}
