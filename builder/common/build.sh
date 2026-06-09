#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"
# shellcheck source=builder/common/load-profile.sh
source "${SCRIPT_DIR}/load-profile.sh"
# shellcheck source=builder/common/read-manifest.sh
source "${SCRIPT_DIR}/read-manifest.sh"
# shellcheck source=builder/common/fetch-sources.sh
source "${SCRIPT_DIR}/fetch-sources.sh"
# shellcheck source=builder/common/verify-checksums.sh
source "${SCRIPT_DIR}/verify-checksums.sh"
# shellcheck source=builder/common/stage-runtime.sh
source "${SCRIPT_DIR}/stage-runtime.sh"
# shellcheck source=builder/common/build-tongsuo.sh
source "${SCRIPT_DIR}/build-tongsuo.sh"
# shellcheck source=builder/common/configure-angie.sh
source "${SCRIPT_DIR}/configure-angie.sh"
# shellcheck source=builder/common/build-angie.sh
source "${SCRIPT_DIR}/build-angie.sh"
# shellcheck source=builder/common/assemble-runtime.sh
source "${SCRIPT_DIR}/assemble-runtime.sh"
# shellcheck source=builder/common/package-rpm.sh
source "${SCRIPT_DIR}/package-rpm.sh"
# shellcheck source=builder/common/package-deb.sh
source "${SCRIPT_DIR}/package-deb.sh"

WORK_ROOT="${REPO_ROOT}/output/work"
PACKAGE_OUTPUT_ROOT="${REPO_ROOT}/output/packages"

extract_source_archive() {
    local archive_path="${1:?archive_path is required}"
    local destination_dir="${2:?destination_dir is required}"
    local temp_dir
    local extracted_root

    log_stage "extract source archive"
    log_info "archive_path=${archive_path}"
    log_info "destination_dir=${destination_dir}"

    rm -rf "${destination_dir}"
    mkdir -p "${destination_dir}"
    temp_dir="$(mktemp -d)"

    case "${archive_path}" in
        *.tar.gz|*.tgz)
            tar -xzf "${archive_path}" -C "${temp_dir}"
            ;;
        *.tar.xz)
            tar -xJf "${archive_path}" -C "${temp_dir}"
            ;;
        *)
            rm -rf "${temp_dir}"
            die "unsupported archive format: ${archive_path}"
            ;;
    esac

    extracted_root="$(find "${temp_dir}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    [[ -n "${extracted_root}" ]] || {
        rm -rf "${temp_dir}"
        die "failed to locate extracted root directory for ${archive_path}"
    }

    cp -a "${extracted_root}/." "${destination_dir}/"
    rm -rf "${temp_dir}"
}

apply_manifest_patches() {
    local manifest_file="${1:?manifest_file is required}"
    local source_dir="${2:?source_dir is required}"
    local patch_file

    while IFS= read -r patch_file; do
        [[ -n "${patch_file}" ]] || continue
        log_stage "apply patch"
        log_info "patch_file=${patch_file}"
        [[ -f "${patch_file}" ]] || die "patch file not found: ${patch_file}"
        (
            cd "${source_dir}"
            patch -p1 < "${REPO_ROOT}/${patch_file}"
        )
    done < <(manifest_get "${manifest_file}" patches)
}

prepare_component_source() {
    local component_name="${1:?component_name is required}"
    local profile_name="${2:?profile_name is required}"
    local manifest_file="${REPO_ROOT}/source/manifests/${component_name}.json"
    local checksum_file upstream_url filename archive_path source_dir

    checksum_file="${REPO_ROOT}/$(manifest_get "${manifest_file}" checksum_file)"
    upstream_url="$(manifest_get "${manifest_file}" upstream_url)"
    filename="$(manifest_get "${manifest_file}" filename)"
    archive_path="$(resolve_or_fetch_source_archive "${upstream_url}" "${filename}")"

    verify_checksum_file_format "${checksum_file}"
    verify_source_archive_checksum "${checksum_file}" "${archive_path}"

    source_dir="${WORK_ROOT}/${profile_name}/sources/${component_name}"
    extract_source_archive "${archive_path}" "${source_dir}"
    apply_manifest_patches "${manifest_file}" "${source_dir}"
}

main() {
    local profile_name="${1:?profile name is required}"
    local profile_dir="${REPO_ROOT}/builder/profiles/${profile_name}"
    local staging_root="${REPO_ROOT}/output/staging/${profile_name}"
    local work_profile_root="${WORK_ROOT}/${profile_name}"
    local angie_source_dir="${work_profile_root}/sources/angie"
    local tongsuo_source_dir="${work_profile_root}/sources/tongsuo"
    local tongsuo_build_root="${work_profile_root}/build/tongsuo"
    local tongsuo_install_root="${work_profile_root}/artifacts/tongsuo"
    local tongsuo_config_args_file="${tongsuo_build_root}/config-args.txt"
    local angie_build_root="${work_profile_root}/build/angie"
    local angie_config_args_file="${angie_build_root}/configure-args.txt"
    local package_output_dir="${PACKAGE_OUTPUT_ROOT}/${profile_name}"
    local package_version="${PACKAGE_VERSION:-0.1.0}"
    local package_release="${PACKAGE_RELEASE:-1}"
    local build_arch="${BUILD_ARCH:-$(uname -m)}"
    local package_format="${PACKAGE_FORMAT:-}"

    load_profile "${profile_dir}"
    print_key_paths

    log_stage "build summary"
    log_info "package_name=${PACKAGE_NAME}"
    log_info "profile_name=${profile_name}"
    log_info "staging_root=${staging_root}"

    prepare_component_source "angie" "${profile_name}"
    prepare_component_source "tongsuo" "${profile_name}"
    prepare_staging_tree "${staging_root}"
    prepare_tongsuo_build "${tongsuo_source_dir}" "${tongsuo_build_root}" "${tongsuo_install_root}" "${tongsuo_config_args_file}"
    build_tongsuo "${tongsuo_source_dir}" "${tongsuo_build_root}" "${tongsuo_install_root}" "${tongsuo_config_args_file}"
    write_angie_configure_args "${angie_config_args_file}" "${tongsuo_source_dir}"
    prepare_angie_build "${angie_source_dir}" "${angie_build_root}" "${angie_config_args_file}"
    build_angie "${angie_source_dir}" "${angie_build_root}" "${angie_config_args_file}" "${staging_root}"
    assemble_runtime "${profile_dir}" "${staging_root}" "${tongsuo_install_root}"
    print_staging_summary "${staging_root}"

    case "${package_format}" in
        rpm)
            package_rpm "${profile_name}" "${staging_root}" "${package_output_dir}/rpm" "${package_version}" "${package_release}" "${build_arch}"
            ;;
        deb)
            package_deb "${profile_name}" "${staging_root}" "${package_output_dir}/deb" "${package_version}" "${package_release}" "${build_arch}"
            ;;
        "")
            log_warn "package format is not set; skip package generation"
            ;;
        *)
            die "unsupported package format: ${package_format}"
            ;;
    esac

    print_self_check_hints
}

main "$@"
