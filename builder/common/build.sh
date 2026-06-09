#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"
# shellcheck source=builder/common/load-profile.sh
source "${SCRIPT_DIR}/load-profile.sh"
# shellcheck source=builder/common/fetch-sources.sh
source "${SCRIPT_DIR}/fetch-sources.sh"
# shellcheck source=builder/common/verify-checksums.sh
source "${SCRIPT_DIR}/verify-checksums.sh"
# shellcheck source=builder/common/stage-runtime.sh
source "${SCRIPT_DIR}/stage-runtime.sh"

main() {
    local profile_name="${1:?profile name is required}"
    local profile_dir="${REPO_ROOT}/builder/profiles/${profile_name}"
    local staging_root="${REPO_ROOT}/output/staging/${profile_name}"

    load_profile "${profile_dir}"
    print_key_paths

    log_stage "build summary"
    log_info "package_name=${PACKAGE_NAME}"
    log_info "profile_name=${profile_name}"
    log_info "staging_root=${staging_root}"

    prepare_staging_tree "${staging_root}"
    print_staging_summary "${staging_root}"

    log_warn "source fetch, patch apply, compile, and package steps are not implemented yet"
    print_self_check_hints
}

main "$@"
