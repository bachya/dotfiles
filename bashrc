set -o vi

# ALIASES
# -----------------------------------------------------------------------------
# Allow sudo with aliases:
alias sudo="sudo "

# General:
alias ls='ls -G'
alias :q='exit'
alias c='clear'
alias cl='clear'
alias g='git'
alias ll='ls -l'
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

# Git:
alias gs='git status'
alias gpu='git push'
alias gmod='git submodule update --recursive --remote'
alias gpl='git pull'
alias gpp='gpl && gmod && gpu'

# HomeBrew:
alias u='brew update && brew upgrade && softwareupdate -i -a'

# Python:
alias venv='virtualenv .venv'
alias vsrc='source .venv/bin/activate'

# Specialized:
export ORIGINAL_PATH=$PATH
alias rsrc='export PATH="$ORIGINAL_PATH" && exec $SHELL -l'
alias ud='$SHELL -c "cd $HOME/dotfiles && git pull && ./init.sh" && rsrc'
alias wmc="ssh ck '/usr/bin/wakeonlan -i 172.16.10.255 -p 9 4C:CC:6A:69:90:D4'"
eval "$(thefuck --alias ugh)"

# BASH COMPLETION
# -----------------------------------------------------------------------------
if type brew &>/dev/null; then
    for COMPLETION in "$(brew --prefix)"/etc/bash_completion.d/*
    do
        # shellcheck source=/dev/null
        [[ -f $COMPLETION ]] && source "$COMPLETION"
    done
    if [[ -f $(brew --prefix)/etc/profile.d/bash_completion.sh ]];
    then
        # shellcheck source=/dev/null
        source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
    fi
fi

__git_complete g __git_main
__git_complete gc _git_checkout
__git_complete gm __git_merge
__git_complete gp _git_pull

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
if [ "$(command -v fasd)" -nt "$fasd_cache" ] | [ ! -s "$fasd_cache" ]; then
    fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
# shellcheck source=/dev/null
source "$fasd_cache"
unset fasd_cache

_fasd_bash_hook_cmd_complete v

# FUNCTIONS
# -----------------------------------------------------------------------------
# usage: copy
# to pipe output to the macOS clipboard
# https://github.com/bag-man/dotfiles/blob/master/bashrc
function copy() {
    if [[ $1 =~ ^-?[hH] ]]; then
        echo "Intelligently copies command results, text file, or raw text"
        echo "to OS X clipboard"
        echo
        echo "Usage: copy [command or text]"
        echo "  or pipe a command: [command] | copy"
        return
    fi

    local output
    local res=false
    local msg=""

    if [[ $# == 0 ]]; then
        output=$(cat)
        msg="Input copied to clipboard"
        res=true
    else
        local cmd=""
        for arg in "$@"; do
            cmd+="\"$(echo -en $arg|sed -E 's/"/\\"/g')\" "
        done
        output=$(eval "$cmd" 2> /dev/null)
        if [[ $? == 0 ]]; then
            msg="Results of command are in the clipboard"
            res=true
        else
            if [[ -f $1 ]]; then
                output=""
                for arg in $@; do
                    if [[ -f $arg ]]; then
                        type=`file "$arg"|grep -c text`
                        if [ $type -gt 0 ]; then
                            output+=$(cat $arg)
                            msg+="Contents of $arg are in the clipboard.\n"
                            res=true
                        else
                            msg+="File \"$arg\" is not plain text.\n"
                        fi
                    fi
                done
            else
                output=$@
                msg="Text copied to clipboard"
                res=true
            fi
        fi
    fi

    $res && echo -ne "$output" | pbcopy -Prefer txt
    echo -e "$msg"
}

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
export PATH

# PROMPT
# -----------------------------------------------------------------------------
function parse_git_dirty {
    [[ -z $(git status --porcelain 2> /dev/null) ]] || echo "*"
}

export PS1='[\[\033[32m\]\w]\[\033[0m\]$(__git_ps1)$(parse_git_dirty)\n\[\033[1;36m\]\u@$(scutil --get ComputerName)\[\033[32m\]$ \[\033[0m\]'

# PYENV
# -----------------------------------------------------------------------------
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi

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

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/__tabtab.bash ] && . ~/.config/tabtab/__tabtab.bash || true
