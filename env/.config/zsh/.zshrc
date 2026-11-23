unsetopt BEEP

export ZDOTDIR="$HOME/dev/env/.config/zsh"

source "$ZDOTDIR/.zsh_aliases"
source "$ZDOTDIR/.zsh_functions"

mkdir -p "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME/zsh"

# configure zsh history
HISTFILE="$XDG_STATE_HOME/zsh/zsh_history"
HISTSIZE=120000
SAVEHIST=120000
setopt HIST_EXPIRE_DUPS_FIRST
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first
setopt SHARE_HISTORY # Share history between windows.
setopt HIST_IGNORE_DUPS # Ignore duplicated commands history list.

# configure completions
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
_comp_options+=(globdots)		# Include hidden files.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# fzf for back-i-search (must be sourced after completions)
export FZF_DEFAULT_OPTS="--no-separator"
if (( $+commands[fzf] )); then
    () {
        local fzf_init fzf_completion
        local fzf_prefix="${commands[fzf]:A:h:h}"
        # Keep our custom key bindings instead of installing fzf's defaults.
        local FZF_CTRL_T_COMMAND='' FZF_ALT_C_COMMAND='' FZF_CTRL_R_COMMAND=''

        if fzf_init=$(fzf --zsh 2>/dev/null); then
            eval "$fzf_init"
        else
            # Older fzf releases ship integration as separate shell scripts.
            for fzf_completion in \
                "$fzf_prefix/shell/completion.zsh" \
                "$fzf_prefix/share/fzf/completion.zsh" \
                "$fzf_prefix/share/fzf/shell/completion.zsh" \
                /usr/share/doc/fzf/examples/completion.zsh \
                "$HOME/.fzf/shell/completion.zsh"; do
                if [[ -r "$fzf_completion" ]]; then
                    source "$fzf_completion"
                    break
                fi
            done
        fi
    }
    source "$ZDOTDIR/fzf.zsh"
fi

# enable vi mode to for traversing the command line
# alt+b - back one word
# alt+w - forward one word
# alt+0 - beginning of line (currently smeared by tms session command)
# alt+$ - end of line
# and more
bindkey -v
export KEYTIMEOUT=1

setopt autocd

bindkey -s '^f' "tmux-sessionizer\n"
bindkey -s '\e7' "tmux-sessionizer -s 0\n"
bindkey -s '\e8' "tmux-sessionizer -s 1\n"
bindkey -s '\e9' "tmux-sessionizer -s 2\n"
bindkey -s '\e0' "tmux-sessionizer -s 3\n" # currently smears "begin line" in shell
bindkey -s '^t' "tmux-todo-finder\n"

# show vcs info without complaints about bare git repos
precmd() {
  vcs_info 2> /dev/null
}

zstyle ':vcs_info:*' enable git
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{green}*'
zstyle ':vcs_info:*' unstagedstr '%F{1}*'
zstyle ':vcs_info:*' formats '%F{green} (%b%u%c%F{green})%f'

# dir only version
PROMPT='%B%F{blue}%~%f%b${vcs_info_msg_0_}%b %(!.#.$) '
# "user@host" version
#PROMPT='%B%F{green}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_}%b %(!.#.$) '

typeset -U path PATH

path+=("$HOME/.local/bin")
path+=("$HOME/.local/scripts")
path+=("$HOME/.local/lua-language-server/bin")
path+=("/usr/lib/postgresql/18/bin")

# python
alias python=python3

# ruby version manager
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

export EDITOR='nvim'
export PAGER="less -R --use-color -Dd+r -Du+b"
export MANPAGER="less -R --use-color -Dd+r -Du+b"
export GROFF_NO_SGR=1

export NVM_DIR="$HOME/.config/nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    nvm node npm npx() {
        local nvm_lazy_command="$0"

        # Remove all wrappers before loading NVM.
        unfunction nvm node npm npx

        source "$NVM_DIR/nvm.sh" -- || return
        if [[ -s "$NVM_DIR/bash_completion" ]]; then
            source "$NVM_DIR/bash_completion"
        fi

        "$nvm_lazy_command" "$@"
    }
fi

eval "$(ssh-agent -s)" > /dev/null
# ssh-add -q ~/.ssh/gitlab ~/.ssh/id_ed25519
