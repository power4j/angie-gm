#!/usr/bin/env bash

set -euo pipefail

log() {
    printf '[smoke-modules] %s\n' "$*"
}

die() {
    printf '[smoke-modules] error: %s\n' "$*" >&2
    exit 1
}

ANGIE_BIN="${ANGIE_BIN:-/usr/sbin/angie}"
MODULE_DIR="${MODULE_DIR:-/opt/angie/modules}"

command -v "${ANGIE_BIN}" >/dev/null 2>&1 || die "missing command: ${ANGIE_BIN}"

log "check=module-directory path=${MODULE_DIR}"
[[ -d "${MODULE_DIR}" ]] || die "module directory not found: ${MODULE_DIR}"

mapfile -t module_files < <(find "${MODULE_DIR}" -maxdepth 1 -type f \( -name '*.so' -o -name '*.so.*' \) | sort)

if [[ "${#module_files[@]}" -eq 0 ]]; then
    die "no dynamic module files found under ${MODULE_DIR}"
fi

temp_conf="$(mktemp)"
trap 'rm -f "${temp_conf}"' EXIT

{
    printf 'user angie angie;\n'
    printf 'pid /tmp/angie-modules.pid;\n'
    printf 'error_log stderr notice;\n'

    for module_file in "${module_files[@]}"; do
        printf 'load_module %s;\n' "${module_file}"
    done

    cat <<'EOF'
events {}

http {
    server {
        listen 127.0.0.1:18082;
        return 200 "modules-check\n";
    }
}
EOF
} > "${temp_conf}"

log "check=load-module-config count=${#module_files[@]}"
if ! "${ANGIE_BIN}" -t -c "${temp_conf}" >/dev/null 2>&1; then
    die "dynamic module load config test failed"
fi

log "result=pass"
