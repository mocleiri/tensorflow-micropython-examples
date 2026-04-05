#!/bin/bash

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)
IDF_DIR="$SCRIPT_DIR/esp-idf"
IDF_EXPORT="$IDF_DIR/export.sh"
IDF_ACTIVATE="$IDF_DIR/tools/activate.py"

die() {
    printf 'ERROR: %s\n' "$*" >&2
    return 1
}

if [ -n "${BASH_SOURCE-}" ] && [ "${BASH_SOURCE[0]}" = "$0" ]; then
    printf '%s\n' "This script must be sourced so it can update your shell environment." >&2
    printf '%s\n' "Run: source ./setup-esp-idf.sh" >&2
    exit 1
fi

if [ ! -d "$IDF_DIR" ] || [ ! -f "$IDF_EXPORT" ] || [ ! -f "$IDF_ACTIVATE" ]; then
    die "ESP-IDF is not set up in $IDF_DIR. Run ./refresh-esp-idf.sh first."
    return 1
fi

printf '%s\n' "--- activating ESP-IDF from $IDF_DIR ---"
# shellcheck disable=SC1090
source "$IDF_EXPORT"
