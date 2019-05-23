# ALIASES
# -----------------------------------------------------------------------------
# allow sudo with aliases
alias sudo="sudo "

# general
alias ls='ls --color=auto'
alias :q='exit'
alias c='clear'
alias cl='clear'
alias cp='rsync -avP'
alias g='git'
alias ll='ls -l'
alias vim='nvim'

# docker
alias dockerkillall='docker kill $(docker ps -q)'
alias dockercleanc='docker ps -a -q | xargs -r docker rm'
alias dockercleani='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias dockercleanv='docker volume rm $(docker volume ls -qf dangling=true)'
alias dockerclean='dockercleanc && dockercleani && dockercleanv'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'

# git
alias gs='git status'
alias gpu='git push'
alias gpl='git pull'
alias gpp='git pull && git push'

# apt-get
alias u='sudo apt-get update && sudo apt-get upgrade'

# specialized
export ORIGINAL_PATH=$PATH
alias rsrc="export PATH=\"$ORIGINAL_PATH\" && exec $SHELL -l"
alias ud="$SHELL -c \"cd $HOME/dotfiles && ./init.sh\" && rsrc"
alias wmc="ssh ck '/usr/bin/wakeonlan -i 172.16.10.255 -p 9 4C:CC:6A:69:90:D4'"

# BASH COMPLETION
# -----------------------------------------------------------------------------
for COMPLETION in "/etc/bash_completion.d/*"
do
    [[ -f $COMPLETION ]] && source "$COMPLETION"
done

complete -f g git

# EXPORTS
# -----------------------------------------------------------------------------
export EDITOR='nvim'
export HISTCONTROL=ignoreboth:erasedups
export HISTFILESIZE=10000
export HISTIGNORE='&:[bf]g:c:clear:history:exit:q:pwd:* --help'
export HISTSIZE=10000
export LANG='en_US'
export LC_ALL='en_US.UTF-8'
export MANPAGER='less -X'
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
export PYTHONIOENCODING='UTF-8'

# FASD
# -----------------------------------------------------------------------------
fasd_cache="$HOME/.fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
    fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache

_fasd_bash_hook_cmd_complete v

# FUNCTIONS
# -----------------------------------------------------------------------------
# usage: tl
# to use FZF to show and switch to available tmux sessions
# https://github.com/bag-man/dotfiles/blob/master/bashrc
function tl() {
    local session
    newsession=${1:-new}
    session=$(tmux list-sessions -F "#{session_name}" | \
        fzf --query="$1" --select-1 --exit-0) &&
        tmux attach-session -t "$session"
    }

# usage: tm
# to use FZF to create a new session
# (creating a new one if there isn't one)
# https://github.com/bag-man/dotfiles/blob/master/bashrc
function tm() {
    local session
    newsession=${1:-new}
    session=$(tmux list-sessions -F "#{session_name}" | \
        fzf --query="$1" --select-1 --exit-0) &&
        tmux attach-session -t "$session" || tmux new-session -s $newsession
    }

# usage: v [path to file or directory]
# to use FZF to pick a file/dir for vim to edit
# https://github.com/junegunn/fzf/wiki/examples#with-fasd
function v() {
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" \
        && vi "${file}" || return 1
    }

# usage: z [directory-fuzz]
# to interactively choose a directory that matches the fuzz and cd to
# it. Note that we have to unalias it first because the default Fasd
# installation uses that alias.
# https://github.com/junegunn/fzf/wiki/examples#with-fasd-1
unalias z
function z() {
    if [ "$#" -gt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "Usage: ${FUNCNAME[0]} [directory-fuzz]" >&2
        return 1
    fi

    local destination
    destination="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)"
    [ -n "$destination" ] && cd "${destination}" || return 1
}

# FZF
# -----------------------------------------------------------------------------
set -o vi
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# PATHS
# -----------------------------------------------------------------------------
PATH="/usr/local/bin:/usr/local/sbin:$PATH"
PATH="$PATH:/bin:/usr/bin:$HOME/.local/bin:$HOME/dotfiles/bin"
export PATH

# PROMPT
# -----------------------------------------------------------------------------
# PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u @ \[\e[33m\]\w\[\e[0m\]/\n$ '
PS1="[\[\033[32m\]\w]\[\033[0m\]\$(__git_ps1)\n\[\033[1;36m\]\u\[\033[32m\]$ \[\
\033[0m\]"

# SHELL OPTIONS
# -----------------------------------------------------------------------------
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dotglob
shopt -s extglob
shopt -s histappend
shopt -s no_empty_cmd_completion
shopt -s nocaseglob

# THEF***
# -----------------------------------------------------------------------------
eval $(thefuck --alias ugh)
