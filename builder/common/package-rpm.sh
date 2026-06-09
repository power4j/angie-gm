#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

map_arch_to_rpm() {
    local arch="${1:?arch is required}"

    case "${arch}" in
        x86_64|amd64)
            printf 'x86_64\n'
            ;;
        aarch64|arm64)
            printf 'aarch64\n'
            ;;
        *)
            die "unsupported rpm arch: ${arch}"
            ;;
    esac
}

package_rpm() {
    local profile_name="${1:?profile_name is required}"
    local staging_root="${2:?staging_root is required}"
    local output_dir="${3:?output_dir is required}"
    local package_version="${4:?package_version is required}"
    local package_release="${5:?package_release is required}"
    local target_arch="${6:?target_arch is required}"
    local rpmbuild_root="${output_dir}/rpmbuild"
    local rpm_arch
    local spec_file="${rpmbuild_root}/SPECS/${PACKAGE_NAME}.spec"
    local release_dir="${output_dir}/release"
    local built_rpm

    log_stage "package rpm"
    log_info "profile_name=${profile_name}"
    log_info "staging_root=${staging_root}"
    log_info "output_dir=${output_dir}"
    log_info "package_version=${package_version}"
    log_info "package_release=${package_release}"
    log_info "target_arch=${target_arch}"

    command -v rpmbuild >/dev/null 2>&1 || die "rpmbuild is required to build rpm packages"

    rpm_arch="$(map_arch_to_rpm "${target_arch}")"

    rm -rf "${rpmbuild_root}" "${release_dir}"
    mkdir -p \
        "${rpmbuild_root}/BUILD" \
        "${rpmbuild_root}/BUILDROOT" \
        "${rpmbuild_root}/RPMS/${rpm_arch}" \
        "${rpmbuild_root}/SOURCES" \
        "${rpmbuild_root}/SPECS" \
        "${rpmbuild_root}/SRPMS" \
        "${release_dir}"

    cat > "${spec_file}" <<EOF
Name:           ${PACKAGE_NAME}
Version:        ${package_version}
Release:        ${package_release}
Summary:        Angie offline package (${PACKAGE_FLAVOR})
License:        BSD
URL:            https://github.com/power4j/angie-gm
BuildArch:      ${rpm_arch}
AutoReqProv:    no
Conflicts:      ${CONFLICTS}
Obsoletes:      ${REPLACES:-}

%description
Offline Angie package for ${PACKAGE_FLAVOR} runtime.

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
cp -a ${staging_root}/. %{buildroot}/

%post
echo "[post] package=${PACKAGE_NAME}"
echo "[post] enabling tmpfiles for angie"
systemd-tmpfiles --create /usr/lib/tmpfiles.d/angie.conf >/dev/null 2>&1 || true
echo "[post] self-check hints: angie -V ; angie -t ; systemctl status angie ; journalctl -u angie -n 100 --no-pager"

%preun
echo "[preun] package=${PACKAGE_NAME}"

%postun
echo "[postun] package=${PACKAGE_NAME}"

%files
%dir /etc/angie
%config(noreplace) /etc/angie/*
/opt/angie
/usr/lib/systemd/system/angie.service
/usr/lib/tmpfiles.d/angie.conf
/usr/sbin/angie
EOF

    rpmbuild \
        --define "_topdir ${rpmbuild_root}" \
        --define "_build_id_links none" \
        -bb "${spec_file}"

    built_rpm="$(find "${rpmbuild_root}/RPMS/${rpm_arch}" -maxdepth 1 -type f -name '*.rpm' | head -n 1)"
    [[ -n "${built_rpm}" ]] || die "failed to locate built rpm package"

    cp -a "${built_rpm}" "${release_dir}/"
    log_info "built_rpm=${release_dir}/$(basename "${built_rpm}")"
}
