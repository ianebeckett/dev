#!/usr/bin/env bash

# runs in both interactive and non-interactive shells
#
# CAUTION: other zsh files are sourced after zshenv, and could overwrite these
# settings
#
# WARNING: do not modify the default behaviour of standard commands here, as
# many tools rely on those. Do so only in .zshrc
# echo "howdy from .zshenv"

export LESSHISTFILE="-"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export ZDOTDIR="$HOME/dev/env/.config/zsh" # TODO: ensure that this isn't making a dir with all file permissions
