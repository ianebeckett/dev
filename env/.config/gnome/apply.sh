#!/bin/sh

set -eu

# Free Super+1 through Super+9 in GNOME Shell and Ubuntu Dock.
for number in 1 2 3 4 5 6 7 8 9; do
    dconf write "/org/gnome/shell/keybindings/switch-to-application-$number" '@as []'
    dconf write "/org/gnome/shell/extensions/dash-to-dock/app-hotkey-$number" '@as []'
done
# Ubuntu Dock uses index 10 for Super+0; GNOME Shell has no equivalent.
dconf write /org/gnome/shell/extensions/dash-to-dock/app-hotkey-10 '@as []'

# Disable Ubuntu Dock.
if command -v gnome-extensions >/dev/null &&
    gnome-extensions info ubuntu-dock@ubuntu.com >/dev/null 2>&1; then
    gnome-extensions disable ubuntu-dock@ubuntu.com
fi
