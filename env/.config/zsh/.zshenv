#!/usr/bin/env bash

# runs in both interactive and non-interactive shells
#
# CAUTION: other zsh files are sourced after zshenv, and could overwrite these
# settings
#
# WARNING: do not modify the default behaviour of standard commands here, as
# many tools rely on those. Do so only in .zshrc

export LESSHISTFILE="-"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export ZDOTDIR="$HOME/dev/env/.config/zsh"
export SHELL_SESSIONS_DISABLE=1

# User-installed tools must also be visible to non-interactive setup scripts.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
    *":$HOME/.local/lua-language-server/bin:"*) ;;
    *) export PATH="$HOME/.local/lua-language-server/bin:$PATH" ;;
esac

# Add Homebrew to PATH on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ $(uname -m) == "arm64" ]]; then
        export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/opt/llvm/bin:/opt/homebrew/bin:$PATH"
    else
        export PATH="/usr/local/opt/ruby/bin:/usr/local/opt/llvm/bin:/usr/local/bin:$PATH"
    fi
fi
