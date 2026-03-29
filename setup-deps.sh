#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# shellcheck disable=SC1091
source "$SCRIPT_DIR/deps.sh"

log() {
    printf '%s\n' "$*"
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

normalize_git_url() {
    printf '%s' "$1" | sed 's#/*$##; s#\.git$##'
}

ensure_repo_checkout() {
    local name="$1"
    local path="$2"
    local url="$3"
    local commit="$4"
    local current_head=""
    local current_url=""

    if [ -e "$path" ] && [ ! -d "$path" ]; then
        die "$path exists but is not a directory"
    fi

    if [ -d "$path" ] && ! git -C "$path" rev-parse --git-dir >/dev/null 2>&1; then
        die "$path already exists but is not a git checkout"
    fi

    if [ -d "$path" ] && git -C "$path" rev-parse --git-dir >/dev/null 2>&1; then
        current_url=$(git -C "$path" remote get-url origin 2>/dev/null || true)
        [ "$(normalize_git_url "$current_url")" = "$(normalize_git_url "$url")" ] || die "$path points at unexpected origin '$current_url' (expected '$url')"

        current_head=$(git -C "$path" rev-parse HEAD)
        if [ "$current_head" != "$commit" ]; then
            die "$path is at $current_head but setup-deps.sh expects $commit; move or remove the directory and rerun"
        fi

        log "--- $name already pinned at $commit ---"
        return
    fi

    log "--- fetching $name ---"
    git init "$path" >/dev/null
    git -C "$path" remote add origin "$url"
    git -C "$path" fetch --depth 1 origin "$commit"
    git -C "$path" checkout --detach FETCH_HEAD >/dev/null
}

ensure_git_submodule_paths() {
    local repo_path="$1"
    shift

    if [ "$#" -eq 0 ]; then
        return
    fi

    log "--- preparing nested git dependencies in $repo_path ---"
    git -C "$repo_path" submodule update --init "$@"
}

ensure_esp32_port_submodules() {
    log "--- preparing Micropython ESP32 port dependencies ---"
    make -C "$SCRIPT_DIR/micropython/ports/esp32" BOARD= submodules
}

ensure_ulab_symlink() {
    local link_path="$SCRIPT_DIR/micropython-modules/ulab"
    local expected_target="../micropython-ulab/code"
    local current_target=""

    if [ -L "$link_path" ]; then
        current_target=$(readlink "$link_path")
        [ "$current_target" = "$expected_target" ] || die "$link_path points to '$current_target' (expected '$expected_target')"
        log "--- micropython-modules/ulab symlink already configured ---"
        return
    fi

    if [ -e "$link_path" ]; then
        die "$link_path exists but is not the expected symlink"
    fi

    log "--- linking micropython-modules/ulab ---"
    ln -s "$expected_target" "$link_path"
}

main() {
    local name=""
    local path=""
    local url=""
    local commit=""

    require_command git
    require_command make

    cd "$SCRIPT_DIR"
    export GIT_TERMINAL_PROMPT=0

    while IFS='|' read -r name path url commit; do
        [ -n "$name" ] || continue
        ensure_repo_checkout "$name" "$path" "$url" "$commit"
    done < <(deps_list)

    ensure_git_submodule_paths "micropython" \
        "lib/axtls" \
        "lib/berkeley-db-1.xx" \
        "lib/pico-sdk" \
        "lib/tinyusb" \
        "lib/mynewt-nimble"
    ensure_esp32_port_submodules
    ensure_git_submodule_paths "tflm_esp_kernels" "components/esp32-camera"
    ensure_ulab_symlink

    log "--- dependency bootstrap complete ---"
}

main "$@"
