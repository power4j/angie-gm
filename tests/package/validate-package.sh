#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
usage: validate-package.sh --package-file <path> --format <deb|rpm> [options]

required:
  --package-file <path>       absolute or relative path to package file
  --format <deb|rpm>          package format

optional:
  --mode <install|replace>    validation mode, default install
  --old-package-file <path>   package file to install first when mode=replace
  --service-name <name>       systemd service name, default angie
  --binary-path <path>        installed angie binary path, default /usr/sbin/angie
  --config-path <path>        installed config path, default /etc/angie/angie.conf
  --keep-package              skip package removal on exit
EOF
}

log() {
    printf '[validate-package] %s\n' "$*"
}

die() {
    printf '[validate-package] error: %s\n' "$*" >&2
    exit 1
}

require_root() {
    [[ "$(id -u)" -eq 0 ]] || die "run as root"
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

PACKAGE_FILE=""
PACKAGE_FORMAT=""
MODE="install"
OLD_PACKAGE_FILE=""
SERVICE_NAME="angie"
BINARY_PATH="/usr/sbin/angie"
CONFIG_PATH="/etc/angie/angie.conf"
KEEP_PACKAGE="false"
PACKAGE_NAME=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --package-file)
            PACKAGE_FILE="${2:?missing value for --package-file}"
            shift 2
            ;;
        --format)
            PACKAGE_FORMAT="${2:?missing value for --format}"
            shift 2
            ;;
        --mode)
            MODE="${2:?missing value for --mode}"
            shift 2
            ;;
        --old-package-file)
            OLD_PACKAGE_FILE="${2:?missing value for --old-package-file}"
            shift 2
            ;;
        --service-name)
            SERVICE_NAME="${2:?missing value for --service-name}"
            shift 2
            ;;
        --binary-path)
            BINARY_PATH="${2:?missing value for --binary-path}"
            shift 2
            ;;
        --config-path)
            CONFIG_PATH="${2:?missing value for --config-path}"
            shift 2
            ;;
        --keep-package)
            KEEP_PACKAGE="true"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown argument: $1"
            ;;
    esac
done

[[ -n "${PACKAGE_FILE}" ]] || die "--package-file is required"
[[ -n "${PACKAGE_FORMAT}" ]] || die "--format is required"
[[ -f "${PACKAGE_FILE}" ]] || die "package file not found: ${PACKAGE_FILE}"
[[ "${MODE}" == "install" || "${MODE}" == "replace" ]] || die "unsupported mode: ${MODE}"

if [[ "${MODE}" == "replace" ]]; then
    [[ -n "${OLD_PACKAGE_FILE}" ]] || die "--old-package-file is required when mode=replace"
    [[ -f "${OLD_PACKAGE_FILE}" ]] || die "old package file not found: ${OLD_PACKAGE_FILE}"
fi

require_root
require_cmd systemctl
require_cmd journalctl

install_deb() {
    local package_file="$1"
    require_cmd dpkg
    apt-get update >/dev/null 2>&1 || true
    dpkg -i "${package_file}"
}

install_rpm() {
    local package_file="$1"
    if command -v dnf >/dev/null 2>&1; then
        dnf install -y "${package_file}"
    elif command -v yum >/dev/null 2>&1; then
        yum install -y "${package_file}"
    elif command -v rpm >/dev/null 2>&1; then
        rpm -Uvh "${package_file}"
    else
        die "missing rpm installer command"
    fi
}

query_name_deb() {
    require_cmd dpkg-deb
    dpkg-deb -f "${PACKAGE_FILE}" Package
}

query_name_rpm() {
    require_cmd rpm
    rpm -qp --queryformat '%{NAME}\n' "${PACKAGE_FILE}"
}

remove_installed_package() {
    local package_name="$1"

    case "${PACKAGE_FORMAT}" in
        deb)
            if dpkg -s "${package_name}" >/dev/null 2>&1; then
                dpkg -P "${package_name}" || dpkg -r "${package_name}" || true
            fi
            ;;
        rpm)
            if rpm -q "${package_name}" >/dev/null 2>&1; then
                if command -v dnf >/dev/null 2>&1; then
                    dnf remove -y "${package_name}" || true
                elif command -v yum >/dev/null 2>&1; then
                    yum remove -y "${package_name}" || true
                else
                    rpm -e "${package_name}" || true
                fi
            fi
            ;;
        *)
            die "unsupported package format: ${PACKAGE_FORMAT}"
            ;;
    esac
}

reset_service_state() {
    systemctl daemon-reload >/dev/null 2>&1 || true
    systemctl reset-failed >/dev/null 2>&1 || true
}

prepare_clean_install_state() {
    local package_name="$1"

    log "prepare-step: ensure clean install state for ${package_name}"
    systemctl stop "${SERVICE_NAME}" >/dev/null 2>&1 || true
    remove_installed_package "${package_name}"
    reset_service_state
}

run_summary_checks() {
    log "self-check: ${BINARY_PATH} -V"
    "${BINARY_PATH}" -V

    log "self-check: ${BINARY_PATH} -t -c ${CONFIG_PATH}"
    "${BINARY_PATH}" -t -c "${CONFIG_PATH}"

    log "self-check: systemctl start ${SERVICE_NAME}"
    systemctl start "${SERVICE_NAME}"

    log "self-check: systemctl is-active ${SERVICE_NAME}"
    systemctl is-active "${SERVICE_NAME}"

    log "self-check: systemctl status ${SERVICE_NAME} --no-pager"
    systemctl status "${SERVICE_NAME}" --no-pager || true

    log "self-check: journalctl -u ${SERVICE_NAME} -n 100 --no-pager"
    journalctl -u "${SERVICE_NAME}" -n 100 --no-pager || true
}

cleanup() {
    if [[ "${KEEP_PACKAGE}" == "true" ]]; then
        log "skip cleanup: keep-package=true"
        return
    fi

    if [[ -n "${PACKAGE_NAME}" ]]; then
        log "cleanup: removing package ${PACKAGE_NAME}"
        systemctl stop "${SERVICE_NAME}" >/dev/null 2>&1 || true
        remove_installed_package "${PACKAGE_NAME}"
        reset_service_state
    fi
}

trap cleanup EXIT

case "${PACKAGE_FORMAT}" in
    deb)
        PACKAGE_NAME="$(query_name_deb)"
        ;;
    rpm)
        PACKAGE_NAME="$(query_name_rpm)"
        ;;
    *)
        die "unsupported package format: ${PACKAGE_FORMAT}"
        ;;
esac

log "package_name=${PACKAGE_NAME}"
log "package_file=${PACKAGE_FILE}"
log "package_format=${PACKAGE_FORMAT}"
log "mode=${MODE}"

if [[ "${MODE}" == "install" ]]; then
    prepare_clean_install_state "${PACKAGE_NAME}"
fi

if [[ "${MODE}" == "replace" ]]; then
    log "replace-step: install old package ${OLD_PACKAGE_FILE}"
    case "${PACKAGE_FORMAT}" in
        deb) install_deb "${OLD_PACKAGE_FILE}" ;;
        rpm) install_rpm "${OLD_PACKAGE_FILE}" ;;
    esac
fi

log "install-step: install target package"
case "${PACKAGE_FORMAT}" in
    deb) install_deb "${PACKAGE_FILE}" ;;
    rpm) install_rpm "${PACKAGE_FILE}" ;;
esac

run_summary_checks

log "validation=pass"
