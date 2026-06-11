#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

load_profile() {
    local profile_dir="${1:?profile_dir is required}"
    local profile_file="${profile_dir}/profile.env"
    local profile_file_lf

    log_stage "load profile"

    [[ -f "${profile_file}" ]] || die "profile file not found: ${profile_file}"

    profile_file_lf="$(mktemp)"
    tr -d '\r' < "${profile_file}" > "${profile_file_lf}"

    # shellcheck disable=SC1090
    source "${profile_file_lf}"
    rm -f "${profile_file_lf}"

    require_profile_var PACKAGE_NAME
    require_profile_var SERVICE_NAME
    require_profile_var INSTALL_PREFIX
    require_profile_var CONF_PREFIX
    require_profile_var STATE_DIR
    require_profile_var CACHE_DIR
    require_profile_var LOG_DIR
    require_profile_var RUN_DIR
}

require_profile_var() {
    local name="${1:?name is required}"
    [[ -n "${!name:-}" ]] || die "required profile variable is empty: ${name}"
}
