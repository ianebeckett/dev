#echo "hello from ~/.config/zsh/.zshrc"

unsetopt BEEP

mkdir -p $XDG_CACHE_HOME/zsh
touch $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
autoload -U compinit && compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION

# vi mode; esc to simulate normal mode; i for insert mode
# TODO: redundant with tmux vi mode?
bindkey -v
export KEYTIMEOUT=1

# TODO: modify tmux-sessionizer and tmux.conf to take these args
bindkey -s '^f' "tmux-sessionizer\n"
#bindkey -s '\eh' "tmux-sessionizer -s 0\n"
#bindkey -s '\ej' "tmux-sessionizer -s 1\n"
#bindkey -s '\ek' "tmux-sessionizer -s 2\n"
#bindkey -s '\el' "tmux-sessionizer -s 3\n"
bindkey -s '^t' "tmux-todo-finder\n"

mkdir -p $XDG_STATE_HOME/zsh
touch $XDG_STATE_HOME/zsh/zsh_history
HISTFILE=$XDG_STATE_HOME/zsh/zsh_history
HISTSIZE=10000
SAVEHIST=1000
setopt INC_APPEND_HISTORY # write to the history file immediately
setopt HIST_EXPIRE_DUPS_FIRST
setopt EXTENDED_HISTORY

source $HOME/.config/zsh/fzf.zsh
source /usr/share/doc/fzf/examples/completion.zsh
# TODO: unhide files that are in their proper xdg config dirs?
source $ZDOTDIR/.zsh_aliases
source $ZDOTDIR/.zsh_functions
addToPath $HOME/.local/bin
addToPath $HOME/.local/scripts
addToPath $HOME/.local/lua-language-server/bin
addToPath /usr/lib/postgresql/18/bin

# precmd runs after executing a command, before the next prompt is printed
# there is also preexec
precmd() {
    print -Pn "\e]0;%~\a";
    vcs_info 2> /dev/null # silence git complaining when working with bare repos
}

# prompt customization
zstyle ':vcs_info:*' enable git
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{1}*'
zstyle ':vcs_info:*' formats '%F{green} (%b%u%F{green})%f'
# keeping my "user@host" version in case I ever need it
# PROMPT='%B%F{green}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_}%b %(!.#.$) '
PROMPT='%B%F{blue}%~%f${vcs_info_msg_0_}%b %(!.#.$) '

# start ssh-agent (keyring already does this on ubuntu: $ ps -aux | grep ssh)
# eval "$(ssh-agent -s)" > /dev/null
# for file in .ssh:
    # ssh-add -q ~/.ssh/foo

# plugins
source ~/.config/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# things addded by outside scripts, e.g. version managers
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
