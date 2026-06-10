#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

copy_tree_contents() {
    local source_dir="${1:?source_dir is required}"
    local target_dir="${2:?target_dir is required}"

    [[ -d "${source_dir}" ]] || die "asset source directory not found: ${source_dir}"

    mkdir -p "${target_dir}"
    cp -a "${source_dir}/." "${target_dir}/"
}

stage_profile_assets() {
    local profile_dir="${1:?profile_dir is required}"
    local staging_root="${2:?staging_root is required}"
    local asset_entry
    local asset_source
    local asset_name
    local target_dir

    while IFS= read -r asset_entry; do
        asset_entry="${asset_entry%$'\r'}"
        [[ -n "${asset_entry}" ]] || continue
        [[ "${asset_entry}" != \#* ]] || continue

        asset_source="${REPO_ROOT}/${asset_entry%/}"
        asset_name="$(basename "${asset_source}")"

        case "${asset_entry}" in
            assets/config/*|assets/config/)
                target_dir="${staging_root}${CONF_PREFIX}"
                ;;
            assets/systemd/*|assets/systemd/)
                target_dir="${staging_root}/usr/lib/systemd/system"
                ;;
            assets/tmpfiles/*|assets/tmpfiles/)
                target_dir="${staging_root}/usr/lib/tmpfiles.d"
                ;;
            assets/diagnostics/*|assets/diagnostics/)
                target_dir="${staging_root}${INSTALL_PREFIX}/bin"
                ;;
            assets/www/*)
                target_dir="${staging_root}${INSTALL_PREFIX}/share/html"
                ;;
            assets/examples/*)
                target_dir="${staging_root}${INSTALL_PREFIX}/share/examples/${asset_name}"
                ;;
            *)
                die "unsupported install asset entry: ${asset_entry}"
                ;;
        esac

        log_info "stage_asset=${asset_entry} -> ${target_dir}"
        copy_tree_contents "${asset_source}" "${target_dir}"
    done < "${profile_dir}/install.assets"
}

stage_runtime_libraries() {
    local tongsuo_install_root="${1:?tongsuo_install_root is required}"
    local staging_root="${2:?staging_root is required}"
    local lib_source="${tongsuo_install_root}/lib"
    local lib_target="${staging_root}${INSTALL_PREFIX}/lib"
    local libcrypt_source

    [[ -d "${lib_source}" ]] || die "tongsuo lib directory not found: ${lib_source}"

    mkdir -p "${lib_target}"
    cp -a "${lib_source}/libcrypto.so"* "${lib_target}/"
    cp -a "${lib_source}/libssl.so"* "${lib_target}/"

    if libcrypt_source="$(find /usr/lib64 /lib64 -maxdepth 1 -type f -name 'libcrypt.so.1*' | head -n 1)"; then
        if [[ -n "${libcrypt_source}" ]]; then
            cp -a "${libcrypt_source}" "${lib_target}/"
            ln -sfn "$(basename "${libcrypt_source}")" "${lib_target}/libcrypt.so.1"
        fi
    fi
}

create_runtime_links() {
    local staging_root="${1:?staging_root is required}"

    mkdir -p "${staging_root}/usr/sbin"
    ln -sfn "../../opt/angie/sbin/angie" "${staging_root}/usr/sbin/angie"
}

create_runtime_directories() {
    local staging_root="${1:?staging_root is required}"

    mkdir -p \
        "${staging_root}${INSTALL_PREFIX}/bin" \
        "${staging_root}${INSTALL_PREFIX}/lib" \
        "${staging_root}${INSTALL_PREFIX}/modules" \
        "${staging_root}${INSTALL_PREFIX}/share/html" \
        "${staging_root}${INSTALL_PREFIX}/share/examples" \
        "${staging_root}${CONF_PREFIX}/conf.d" \
        "${staging_root}${CONF_PREFIX}/modules.d"
}

stage_dynamic_module_loaders() {
    local profile_dir="${1:?profile_dir is required}"
    local staging_root="${2:?staging_root is required}"
    local dynamic_module_list="${profile_dir}/modules.dynamic"
    local modules_dir="${staging_root}${CONF_PREFIX}/modules.d"
    local dynamic_module
    local conf_name
    local module_path

    mkdir -p "${modules_dir}"
    find "${modules_dir}" -maxdepth 1 -type f -name '*.conf' -delete

    [[ -f "${dynamic_module_list}" ]] || return

    while IFS= read -r dynamic_module; do
        dynamic_module="${dynamic_module%$'\r'}"
        [[ -n "${dynamic_module}" ]] || continue
        [[ "${dynamic_module}" != \#* ]] || continue

        case "${dynamic_module}" in
            stream)
                conf_name="10-stream.conf"
                module_path="${INSTALL_PREFIX}/modules/ngx_stream_module.so"
                ;;
            mail)
                conf_name="20-mail.conf"
                module_path="${INSTALL_PREFIX}/modules/ngx_mail_module.so"
                ;;
            *)
                die "unsupported runtime dynamic module entry: ${dynamic_module}"
                ;;
        esac

        printf 'load_module %s;\n' "${module_path}" > "${modules_dir}/${conf_name}"
    done < "${dynamic_module_list}"
}

finalize_permissions() {
    local staging_root="${1:?staging_root is required}"
    local diag_script="${staging_root}${INSTALL_PREFIX}/bin/angie-diagnose"

    if [[ -f "${diag_script}" ]]; then
        chmod 0755 "${diag_script}"
    fi
}

assemble_runtime() {
    local profile_dir="${1:?profile_dir is required}"
    local staging_root="${2:?staging_root is required}"
    local tongsuo_install_root="${3:?tongsuo_install_root is required}"

    log_stage "assemble runtime"
    log_info "profile_dir=${profile_dir}"
    log_info "staging_root=${staging_root}"
    log_info "tongsuo_install_root=${tongsuo_install_root}"

    [[ -d "${staging_root}${INSTALL_PREFIX}" ]] || die "angie install root not found in staging: ${staging_root}${INSTALL_PREFIX}"
    [[ -d "${staging_root}${CONF_PREFIX}" ]] || die "angie config root not found in staging: ${staging_root}${CONF_PREFIX}"

    create_runtime_directories "${staging_root}"
    stage_runtime_libraries "${tongsuo_install_root}" "${staging_root}"
    stage_profile_assets "${profile_dir}" "${staging_root}"
    stage_dynamic_module_loaders "${profile_dir}" "${staging_root}"
    create_runtime_links "${staging_root}"
    finalize_permissions "${staging_root}"
}
