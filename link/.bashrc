# .bashrc

# Platform
platform="Unknown"
unamestr=$(uname -s)
if [[ "$unamestr" == 'Linux' ]]; then
    platform="Linux"
elif [[ "$unamestr" == 'FreeBSD' ]]; then
    platform="BSD"
elif [[ "$unamestr" == 'Darwin' ]]; then
    platform="OSX"
elif [[ "$unamestr" == CYGWIN* ]]; then
    platform="Cygwin"
elif [[ "$unamestr" == MSYS* ]]; then
    platform="Windows"
elif [[ "$unamestr" == MINGW* ]]; then
    platform="MinGW"
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

_INTERACTIVE_MODE=
case "$-" in
    *i*) _INTERACTIVE_MODE=1 ;;
esac

# Function to verbosely source files (if interactive) and
function _source {
    if test -e "$1"; then
        if [ "$_INTERACTIVE_MODE" ]; then
            echo -e "Sourcing\t[$1]"
        fi
        source "$1"
        return 0
    else
        if [ "$_INTERACTIVE_MODE" ]; then
            echo -e "Not sourcing\t[$1]"
        fi
    fi
    return 1
}

ST_START='\033k'
ST_STOP='\033\\'

### BEGIN screen preexec / premd trickery ###
microtime() {
    python -c 'import time; print time.time()'
}
# If runing in screen, set the window title to the command about to be executed
#last_history_line=0
preexec () {
    echo -en $ST_START$1$ST_STOP
    PRE_CMD_TIME=$(microtime)
}

### END screen preexec / postexec trickery ###

##
# Show the background jobs in a dialog
##
jobmenu () {
    read jid garbage < <(jobs | simpledialog | awk '{print $1}' | tr -c -d ' 0-9')
    if [ "$jid" ]; then
        fg $jid;
    fi
}

jobmenu ()
{
    read jid < <(jobs | simpledialog | awk '{print $1}' | grep -o "[0-9]\{1,\}") && fg $jid;
}

if [ "$_INTERACTIVE_MODE" ]; then
    bind -r "\C-j" # Who uses ctrl-j instead of the "enter" key anyway?
    bind -x '"\C-j":jobmenu'
fi


if [ -z "$TERM_TITLE" ]; then
    TERM_TITLE="${HOSTNAME/.*/}"
fi

if [ "$_INTERACTIVE_MODE" ]; then
    echo "Terminal set to: [$TERM - $-]" 1>&2
    if ! _source $HOME/bin/termcolors; then
        echo "No terminal color file found. Terminal will be boring."
    fi
    if ! _source $HOME/bin/.bash-preexec.sh; then
        echo "No preexec found"
    fi
fi

function get_job_str {
    if [ "$1" = "0" ]; then
        jobstr=""
    else
        jobstr=" [$1]"
    fi
    echo "$jobstr"
}

export HISTCMD
function precmd() {
    CMD_STATUS=$?

    echo -en '\033kprompt\033\\'
    CHC=$(history 1)

    if [ "$TERM" == "screen" -a "$_INTERACTIVE_MODE" ]; then
        echo -ne "\033]0;${HOSTNAME}: ${PWD}\007" # Set window title for Gnome Terminal
    fi

    # Set PS1
    PS1_TIME_COLOR="\[$magenta_ctrl\]"
    PS1_USER_COLOR="\[$cyan_ctrl\]"
    PS1_HOST_COLOR="\[$cyan_ctrl\]"
    PS1_JOBS_COLOR="\[$cyan_ctrl\]"
    PS1_PATH_COLOR="\[$cyan_ctrl\]"
    PS1_DOLLAR_COLOR="\[$cyan_ctrl\]"
    PS1_GIT_COLOR="\[$yellow_ctrl\]"
    PS1_RST="\[$reset_ctrl\]"

    if [ "$PRE_CMD_TIME" != "" ]; then
        if [ $CMD_STATUS -eq 0 ]; then
            PS1_EXIT_COLOR="\[$green_ctrl\]"
            PS1_EXIT_MARK="✓" # Check mark (\xE2\x9C\x93)
        elif [ "$CMD_STATUS" -gt 0 ]; then
            PS1_EXIT_COLOR="\[$red_ctrl\]"
            PS1_EXIT_MARK="✕" # X (\xE2\x9C\x95)
        fi
    else
        PS1_EXIT_COLOR="$PS1_RST"
        PS1_EXIT_MARK=" "
    fi
    LHC=$CHC

    if ! type __git_ps1 &>/dev/null; then
        PS1_GIT_INFO=""
    else
        PS1_GIT_INFO="$(__git_ps1)"
    fi
    PS1=""
    if [ "$TERM" == "screen" ]; then
        # GNU Screen: num jobs
        # Note: The whole thing is non-printing as far as bash is concerned
        NOTHING=""
        #PS1+="\[${ST_START}${TERM_TITLE}"'$(get_job_str \j)'"${ST_STOP}\]"
    fi
    PS1+="${PS1_EXIT_COLOR}${PS1_EXIT_MARK}${PS1_RST} "
    PS1+="[${PS1_TIME_COLOR}\D{%F %T}${PS1_RST}]-"
    if [ "$PRE_CMD_TIME" != "" ]; then
        POST_CMD_TIME="$(microtime)"
        CMD_TIME=$(echo $POST_CMD_TIME - $PRE_CMD_TIME | bc)
        PRE_CMD_TIME=""
        PS1+="[${PS1_TIME_COLOR}$CMD_TIME${PS1_RST}]-"
    fi
    PS1+="[${PS1_USER_COLOR}\u${PS1_RST}@$PS1_HOST_COLOR\h${PS1_RST}]-"
    PS1+="[${PS1_JOBS_COLOR}\j${PS1_RST}]-"
    PS1+="[${PS1_PATH_COLOR}\w${PS1_RST}]"
    PS1+="${PS1_GIT_COLOR}${PS1_GIT_INFO}${PS1_RST} "
    PS1+="${PS1_DOLLAR_COLOR}\$${PS1_RST} "
}

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias branch='git branch | grep "\*" | cut -d" " -f 2'
#alias python='python -i'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

export EDITOR=vim
export DISPLAY=:0.0

# All
export FORCE_COLOR=1
export PATH=$HOME/bin:$PATH

echo Platform: $platform
case $platform in
    Linux)
        ;;
    BSD)
        ;;
    OSX)
        export NVM_DIR=~/.nvm
        source $(brew --prefix nvm)/nvm.sh
        PATH="/usr/local/opt/llvm/bin/:$PATH"
        ;;
    Windows)
        ;;
    Cygwin)
        ;;
    *)
        ;;
esac

if ! _source $HOME/bin/ssh-find-agent.sh; then
    echo "No ssh-find-agent found in $HOME/bin"
fi
ssh-find-agent -a
if [ -z "$SSH_AUTH_SOCK" ]
then
   eval $(ssh-agent) > /dev/null
   ssh-add -l >/dev/null || alias ssh='ssh-add -l >/dev/null || ssh-add && unalias ssh; ssh'
fi
