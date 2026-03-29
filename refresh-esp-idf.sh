#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

CI_SCRIPT="$SCRIPT_DIR/micropython/tools/ci.sh"
IDF_DIR="$SCRIPT_DIR/esp-idf"

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

main() {
    require_command git
    require_command pip3

    [ -f "$CI_SCRIPT" ] || die "missing Micropython CI helper at $CI_SCRIPT; run ./setup-deps.sh first"

    cd "$SCRIPT_DIR"

    if [ -e "$IDF_DIR" ]; then
        printf '%s\n' "--- removing existing esp-idf checkout at $IDF_DIR ---"
        rm -rf "$IDF_DIR"
    fi

    printf '%s\n' "--- provisioning ESP-IDF using Micropython's ci_esp32_idf44_setup helper ---"
    # shellcheck disable=SC1090
    source "$CI_SCRIPT"
    ci_esp32_idf44_setup

    printf '%s\n' "--- ESP-IDF ready: source ./esp-idf/export.sh ---"
}

main "$@"
