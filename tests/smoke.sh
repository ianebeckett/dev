#!/usr/bin/env bash

set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
trap 'printf "Smoke check failed at line %s\n" "$LINENO" >&2' ERR

export HOME="$tmp/home with spaces"
unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME ZDOTDIR
dev="$HOME/dev"
mkdir -p "$dev/runs/installers" "$dev/lib" "$dev/env/.config/zsh" "$dev/env/.local/scripts"
cp "$repo_dir/runner" "$dev/runner"
cp "$repo_dir/lib/links.sh" "$dev/lib/links.sh"
cp "$repo_dir/env/.config/zsh/.zshenv" "$repo_dir/env/.config/zsh/.zshrc" "$dev/env/.config/zsh/"
for script in installs neovim scripts sway tmux tmux-sessionizer zsh; do
    cp "$repo_dir/runs/$script" "$dev/runs/$script"
done
for config in nvim sway tmux tmux-sessionizer; do
    mkdir -p "$dev/env/.config/$config"
done

# Stub package installers; the real dispatcher and configuration scripts run.
printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\n" "${0##*/}" >> "$HOME/events"' \
    'exit "$INSTALL_STATUS"' > "$dev/runs/installers/linux"
cp "$dev/runs/installers/linux" "$dev/runs/installers/macos"
printf '%s\n' \
    '#!/usr/bin/env bash' \
    '[[ "$XDG_CONFIG_HOME" == "$HOME/.config" ]] || exit 1' \
    'printf "config\n" >> "$HOME/events"' > "$dev/runs/a-config"
chmod +x "$dev/runs/installers/"* "$dev/runs/a-config"
export INSTALL_STATUS=0
case "$OSTYPE" in
    linux-gnu*) platform=linux ;;
    darwin*) platform=macos ;;
    *) printf 'Unsupported test platform: %s\n' "$OSTYPE" >&2; exit 1 ;;
esac

# A filtered dry-run selects just tmux and leaves the fixture home unconfigured.
output=$("$dev/runner" --dry-run '/tmux$')
[[ "$output" == *'[dry-run]: execute ./runs/tmux'* ]]
[[ "$output" != *'execute ./runs/installs'* && "$output" != *'execute ./runs/tmux-sessionizer'* ]]
[[ ! -e "$HOME/events" && ! -d "$HOME/.config" ]]
printf 'PASS: dry-run selection\n'

# Installation precedes configuration; a second run preserves correct links.
for attempt in 1 2; do
    : > "$HOME/events"
    "$dev/runner" >/dev/null
    [[ "$(<"$HOME/events")" == "$platform"$'\nconfig' ]]
    for config in nvim sway tmux tmux-sessionizer zsh; do
        [[ "$(readlink "$HOME/.config/$config")" == "$dev/env/.config/$config" ]]
        [[ ! -L "$dev/env/.config/$config/$config" ]]
    done
    [[ "$(readlink "$HOME/.local/scripts")" == "$dev/env/.local/scripts" ]]
    [[ "$(readlink "$HOME/.zshenv")" == "$dev/env/.config/zsh/.zshenv" ]]
    [[ "$(readlink "$HOME/.zshrc")" == "$dev/env/.config/zsh/.zshrc" ]]
    [[ -d "$HOME/.cache/tmux-sessionizer" && ! -L "$HOME/.cache/tmux-sessionizer" ]]
    [[ -d "$HOME/.cache/zsh" && -d "$HOME/.local/state/zsh" ]]
done
printf 'PASS: install-first dispatch and repeatable linking\n'

# A failed installer returns its status and prevents configuration from running.
: > "$HOME/events"
export INSTALL_STATUS=23
if output=$("$dev/runner" 2>&1); then
    printf 'Expected the installer failure to stop the runner\n' >&2
    exit 1
else
    [[ $? -eq 23 ]]
fi
[[ "$(<"$HOME/events")" == "$platform" ]]
[[ "$output" == *'./runs/installs failed (exit status 23)'* ]]
printf 'PASS: failure propagation\n'
