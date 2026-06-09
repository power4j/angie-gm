#!/usr/bin/env bash

set -euo pipefail

log_stage() {
    printf '[stage] %s\n' "$*"
}

log_info() {
    printf '[info] %s\n' "$*"
}

log_warn() {
    printf '[warn] %s\n' "$*" >&2
}

log_error() {
    printf '[error] %s\n' "$*" >&2
}

die() {
    log_error "$*"
    exit 1
}

print_key_paths() {
    log_info "install_prefix=${INSTALL_PREFIX:-unset}"
    log_info "conf_prefix=${CONF_PREFIX:-unset}"
    log_info "state_dir=${STATE_DIR:-unset}"
    log_info "cache_dir=${CACHE_DIR:-unset}"
    log_info "log_dir=${LOG_DIR:-unset}"
    log_info "run_dir=${RUN_DIR:-unset}"
}

print_self_check_hints() {
    log_info 'self-check: angie -V'
    log_info 'self-check: angie -t'
    log_info 'self-check: systemctl status angie'
    log_info 'self-check: journalctl -u angie -n 100 --no-pager'
}
