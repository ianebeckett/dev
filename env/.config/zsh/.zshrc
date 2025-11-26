unsetopt BEEP

source $ZDOTDIR/.zsh_aliases
source $ZDOTDIR/.zsh_functions

# configure zsh history
HISTFILE=$XDG_STATE_HOME/zsh/zsh_history
HISTSIZE=10000
SAVEHIST=1000
setopt INC_APPEND_HISTORY # write to the history file immediately
setopt HIST_EXPIRE_DUPS_FIRST
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first
setopt SHARE_HISTORY # Share history between windows.
setopt HIST_IGNORE_DUPS # Ignore duplicated commands history list.

# configure completions
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
_comp_options+=(globdots)		# Include hidden files.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# fzf for back-i-search (must be sourced after completions)
source $HOME/.config/zsh/fzf.zsh
source /usr/share/doc/fzf/examples/completion.zsh

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
zstyle ':vcs_info:*' unstagedstr '%F{1}*'
zstyle ':vcs_info:*' formats '%F{green} (%b%u%F{green})%f'

PROMPT='%B%F{blue}%~%f%b${vcs_info_msg_0_}%b %(!.#.$) '
# "user@host" version
# PROMPT='%B%F{green}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_}%b %(!.#.$) '

# start ssh-agent (keyring already does this on ubuntu: $ ps -aux | grep ssh)
# eval "$(ssh-agent -s)" > /dev/null
# for file in .ssh:
    # ssh-add -q ~/.ssh/foo

addToPath $HOME/.local/bin
addToPath $HOME/.local/scripts
addToPath $HOME/.local/lua-language-server/bin
addToPath /usr/lib/postgresql/18/bin
addToPath /usr/local/go/bin
addToPath $HOME/go/bin
. "$HOME/.cargo/env" # rust

export EDITOR='vim'

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
