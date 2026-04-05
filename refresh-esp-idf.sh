#!/bin/bash

set -euo pipefail

SCRIPT_DIR=.

CI_SCRIPT="$SCRIPT_DIR/micropython/tools/ci.sh"
MICROPY_DIR="$SCRIPT_DIR/micropython"
IDF_DIR="$SCRIPT_DIR/esp-idf"
MICROPY_IDF_DIR="$MICROPY_DIR/esp-idf"

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
    if [ -e "$MICROPY_IDF_DIR" ]; then
        printf '%s\n' "--- removing existing esp-idf checkout at $MICROPY_IDF_DIR ---"
        rm -rf "$MICROPY_IDF_DIR"
    fi

    printf '%s\n' "--- provisioning ESP-IDF using Micropython's ci_esp32_idf_setup helper ---"
    (
        cd "$MICROPY_DIR"
        # shellcheck disable=SC1090
        set +u
        source "$CI_SCRIPT"
        set -u
        ci_esp32_idf_setup
    )

    if [ -d "$MICROPY_IDF_DIR" ]; then
        mv "$MICROPY_IDF_DIR" "$IDF_DIR"
    fi

    printf '%s\n' "--- ESP-IDF ready: source ./esp-idf/export.sh ---"
}

main "$@"
