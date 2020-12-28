set -o vi

# ALIASES
# -----------------------------------------------------------------------------
# Allow sudo with aliases:
alias sudo="sudo "

# General:
alias :q='exit'
alias c='clear'
alias cl='clear'
alias fd='fdfind'
alias g='git'
alias ll='ls -al'
alias ls='ls --color=auto'
alias vim='nvim'

# Docker:
alias dockerkillall='docker kill $(docker ps -q)'
alias dockercleanc='docker ps -a -q | xargs -r docker rm'
alias dockercleani='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias dockercleanv='docker volume rm $(docker volume ls -qf dangling=true)'
alias dockerclean='dockercleanc && dockercleani && dockercleanv'

# Espanso
alias ee='espanso edit'

# Navigation:
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'
alias r='ranger'

# Git:
alias gs='git status'
alias gpu='git push'
alias gmod='git submodule update --recursive --remote'
alias gpl='git pull'
alias gpp='gpl && gmod && gpu'

# apt-get
alias u='sudo apt-get update && sudo apt-get upgrade && sudo apt-get autoremove'

# Specialized:
export ORIGINAL_PATH=$PATH
alias rsrc="export PATH=\"$ORIGINAL_PATH\" && exec $SHELL -l"
alias ud="$SHELL -c \"cd $HOME/dotfiles && git pull && ./init.sh\" && rsrc"
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
export GOPATH="${HOME}/.go"
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

# EVALS
# -----------------------------------------------------------------------------
eval "$(starship init bash)"
eval "$(thefuck --alias ugh)"

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
# usage: kp
# to show output of "ps -ef", use [tab] to select one or multiple entries
# press [enter] to kill selected processes and go back to the process list.
# or press [escape] to go back to the process list. Press [escape] twice to
# exit completely.
function kp() {
    local pid=$(ps -ef | sed 1d | eval "fzf ${FZF_DEFAULT_OPTS} -m --header='[kill:process]'" | awk '{print $2}')
    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
        kp
    fi
}

# usage: tl
# to use FZF to show and switch to available tmux sessions
# https://github.com/bag-man/dotfiles/blob/master/bashrc
function tl() {
    local session
    newsession=${1:-new}
    session=$(tmux list-sessions -F "#{session_name}" | \
        fzf --reverse --query="$1" --select-1 --exit-0) &&
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
        fzf --reverse --query="$1" --select-1 --exit-0) &&
        tmux attach-session -t "$session" || tmux new-session -s $newsession
}

# usage: v [path to file or directory]
# to use FZF to pick a file/dir for vim to edit
# https://github.com/junegunn/fzf/wiki/examples#with-fasd
function v() {
    local file
    file="$(fzf -1 -0 +m --query="$1")" \
        && vim "${file}" || return 1
}

# usage: venv
# to create a Python virtual env for the current directory
function venv() {
    mkvirtualenv "$(basename "$(pwd)")"
}

# usage: vg [search text]
# to search for text with ripgrep and optionally open the result in Vim
function vg() {
    local file
    local line_number
    local result

    result="$(rg -i --line-number "$1" | fzf)"

    if [ -z "$result" ]; then
        return 1
    fi

    file="$(echo "$result" | awk -F':' '{ print $1 }')"
    line_number="$(echo "$result" | awk -F':' '{ print $2 }')"
    vim "+$line_number" "$file"
}

# usage: vsrcj
# to use the Python virtual env for the current directory
function vsrc() {
    workon "$(basename "$(pwd)")"
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
    destination="$(fasd -Rdl "$1" | fzf -1 -0 --reverse --no-sort +m)"
    [ -n "$destination" ] && cd "${destination}" || return 1
}

# FZF
# -----------------------------------------------------------------------------
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--bind J:down,K:up --reverse --ansi '

# NVM
# -----------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PATHS
# -----------------------------------------------------------------------------
PATH="/usr/local/bin:/usr/local/sbin:$PATH"
PATH="$PATH:/bin:/usr/bin:$HOME/.local/bin:$HOME/dotfiles/bin"
PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
PATH="$HOME/.poetry/bin:$PATH"
PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
export PATH

# PYTHON VENV STUFF
# -----------------------------------------------------------------------------
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source "$(command -v virtualenvwrapper.sh)"

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

# STARTUP
# -----------------------------------------------------------------------------
SSH_ENV="$HOME/.ssh/environment"
function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
