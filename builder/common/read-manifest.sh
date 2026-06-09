#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=builder/common/diagnostics.sh
source "${SCRIPT_DIR}/diagnostics.sh"

require_python3() {
    command -v python3 >/dev/null 2>&1 || die "python3 is required to parse manifest json"
}

manifest_get() {
    local manifest_file="${1:?manifest_file is required}"
    local key="${2:?key is required}"

    [[ -f "${manifest_file}" ]] || die "manifest file not found: ${manifest_file}"
    require_python3

    python3 - "${manifest_file}" "${key}" <<'PY'
import json
import sys

manifest_file = sys.argv[1]
key = sys.argv[2]

with open(manifest_file, "r", encoding="utf-8") as fh:
    data = json.load(fh)

value = data
for part in key.split("."):
    value = value[part]

if isinstance(value, list):
    for item in value:
        print(item)
elif isinstance(value, bool):
    print("true" if value else "false")
else:
    print(value)
PY
}
