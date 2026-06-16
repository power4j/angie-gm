#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

write_angie_configure_args() {
    local output_file="${1:?output_file is required}"
    local tongsuo_source_dir="${2:?tongsuo_source_dir is required}"
    local profile_dir="${3:?profile_dir is required}"
    local output_dir
    local dynamic_module_list="${profile_dir}/modules.dynamic"
    local dynamic_module

    output_dir="$(dirname "${output_file}")"

    log_stage "write angie configure args"
    log_info "output_file=${output_file}"
    log_info "tongsuo_source_dir=${tongsuo_source_dir}"
    log_info "profile_dir=${profile_dir}"

    mkdir -p "${output_dir}"

    {
        printf '%s\n' "--prefix=${INSTALL_PREFIX}"
        printf '%s\n' "--conf-path=${CONF_PREFIX}/angie.conf"
        printf '%s\n' "--http-log-path=${LOG_DIR}/access.log"
        printf '%s\n' "--error-log-path=${LOG_DIR}/error.log"
        printf '%s\n' "--pid-path=${RUN_DIR}/angie.pid"
        printf '%s\n' "--lock-path=${RUN_DIR}/angie.lock"
        printf '%s\n' "--modules-path=${INSTALL_PREFIX}/modules"
        printf '%s\n' "--with-compat"
        printf '%s\n' "--with-pcre-jit"
        printf '%s\n' "--with-ld-opt=-Wl,-rpath,${INSTALL_PREFIX}/lib"
        printf '%s\n' "--with-openssl=${tongsuo_source_dir}"
        printf '%s\n' "--with-openssl-opt=enable-ntls"

        if [[ "${ENABLE_HTTP3}" == "true" ]]; then
            printf '%s\n' "--with-http_v3_module"
        fi

        if [[ "${ENABLE_STREAM}" == "true" ]]; then
            printf '%s\n' "--with-stream"
            printf '%s\n' "--with-stream_ssl_module"
            printf '%s\n' "--with-stream_ssl_preread_module"
        fi

        if [[ "${ENABLE_NTLS}" == "true" ]]; then
            printf '%s\n' "--with-http_ssl_module"
            printf '%s\n' "--with-ntls"
        fi

        if [[ -f "${dynamic_module_list}" ]]; then
            while IFS= read -r dynamic_module; do
                dynamic_module="${dynamic_module%$'\r'}"
                [[ -n "${dynamic_module}" ]] || continue
                [[ "${dynamic_module}" != \#* ]] || continue

                case "${dynamic_module}" in
                    stream)
                        printf '%s\n' "--with-stream=dynamic"
                        ;;
                    mail)
                        printf '%s\n' "--with-mail=dynamic"
                        ;;
                    *)
                        die "unsupported dynamic module entry: ${dynamic_module}"
                        ;;
                esac
            done < "${dynamic_module_list}"
        fi

        if [[ "${WITH_DEBUG}" == "true" ]]; then
            printf '%s\n' "--with-debug"
        fi
    } > "${output_file}"
}
