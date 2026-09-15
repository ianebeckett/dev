#!/usr/bin/env bash

link_config() {
    local source="$1"
    local destination="$2"

    if [[ ! -e "$source" ]]; then
        printf 'Error: configuration source does not exist: %s\n' "$source" >&2
        return 1
    fi

    if [[ -L "$destination" ]]; then
        if [[ "$(readlink "$destination")" == "$source" ]]; then
            return 0
        fi
    elif [[ -e "$destination" ]]; then
        printf 'Error: destination exists and is not a symlink: %s\n' "$destination" >&2
        return 1
    fi

    mkdir -p "$(dirname "$destination")" || return
    ln -sfn "$source" "$destination"
}
