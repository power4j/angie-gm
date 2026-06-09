#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

map_arch_to_deb() {
    local arch="${1:?arch is required}"

    case "${arch}" in
        x86_64)
            printf 'amd64\n'
            ;;
        amd64)
            printf 'amd64\n'
            ;;
        aarch64|arm64)
            printf 'arm64\n'
            ;;
        *)
            die "unsupported deb arch: ${arch}"
            ;;
    esac
}

require_deb_tools() {
    command -v ar >/dev/null 2>&1 || die "ar is required to build deb packages"
    command -v tar >/dev/null 2>&1 || die "tar is required to build deb packages"
}

write_deb_script() {
    local script_path="${1:?script_path is required}"
    local phase="${2:?phase is required}"

    cat > "${script_path}" <<EOF
#!/bin/sh
set -eu
echo "[${phase}] package=${PACKAGE_NAME}"
if [ "${phase}" = "postinst" ]; then
    systemd-tmpfiles --create /usr/lib/tmpfiles.d/angie.conf >/dev/null 2>&1 || true
    echo "[${phase}] self-check hints: angie -V ; angie -t ; systemctl status angie ; journalctl -u angie -n 100 --no-pager"
fi
exit 0
EOF
    chmod 0755 "${script_path}"
}

package_deb() {
    local profile_name="${1:?profile_name is required}"
    local staging_root="${2:?staging_root is required}"
    local output_dir="${3:?output_dir is required}"
    local package_version="${4:?package_version is required}"
    local package_release="${5:?package_release is required}"
    local target_arch="${6:?target_arch is required}"
    local deb_arch
    local deb_root="${output_dir}/debroot"
    local control_dir="${deb_root}/DEBIAN"
    local release_dir="${output_dir}/release"
    local payload_root="${output_dir}/payload"
    local debian_binary_file="${output_dir}/debian-binary"
    local control_tar_file="${output_dir}/control.tar.gz"
    local data_tar_file="${output_dir}/data.tar.gz"
    local package_file

    log_stage "package deb"
    log_info "profile_name=${profile_name}"
    log_info "staging_root=${staging_root}"
    log_info "output_dir=${output_dir}"
    log_info "package_version=${package_version}"
    log_info "package_release=${package_release}"
    log_info "target_arch=${target_arch}"

    require_deb_tools

    deb_arch="$(map_arch_to_deb "${target_arch}")"

    rm -rf "${deb_root}" "${payload_root}" "${release_dir}" "${control_tar_file}" "${data_tar_file}" "${debian_binary_file}"
    mkdir -p "${control_dir}" "${payload_root}" "${release_dir}"
    cp -a "${staging_root}/." "${payload_root}/"

    cat > "${control_dir}/control" <<EOF
Package: ${PACKAGE_NAME}
Version: ${package_version}-${package_release}
Section: net
Priority: optional
Architecture: ${deb_arch}
Maintainer: power4j
Conflicts: ${CONFLICTS}
Replaces: ${REPLACES}
Description: Offline Angie package (${PACKAGE_FLAVOR})
 Offline Angie package for ${PACKAGE_FLAVOR} runtime.
EOF

    cat > "${control_dir}/conffiles" <<EOF
/etc/angie/angie.conf
/etc/angie/fastcgi.conf
/etc/angie/fastcgi_params
/etc/angie/mime.types
/etc/angie/prometheus_all.conf
/etc/angie/scgi_params
/etc/angie/uwsgi_params
EOF

    write_deb_script "${control_dir}/postinst" "postinst"
    write_deb_script "${control_dir}/prerm" "prerm"
    write_deb_script "${control_dir}/postrm" "postrm"

    package_file="${release_dir}/${PACKAGE_NAME}_${package_version}-${package_release}_${deb_arch}.deb"
    printf '2.0\n' > "${debian_binary_file}"

    (
        cd "${control_dir}"
        tar -czf "${control_tar_file}" .
    )

    (
        cd "${payload_root}"
        tar -czf "${data_tar_file}" .
    )

    (
        cd "${output_dir}"
        ar r "${package_file}" \
            "$(basename "${debian_binary_file}")" \
            "$(basename "${control_tar_file}")" \
            "$(basename "${data_tar_file}")"
    )

    log_info "built_deb=${package_file}"
}
