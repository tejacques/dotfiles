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

### BEGIN screen preexec / premd trickery ###

# If runing in screen, set the window title to the command about to be executed
#last_history_line=0
preexec () {
    echo -en '\033k'$1'\033\\'
}
_invoke_exec () {
    if [ -n "$COMP_LINE" ]
    then
        postexec
    else
         # current_history_line=`history 1 | awk '{print $1}'` ;
         # if [ $current_history_line -gt $last_history_line ]
         # then
            # last_history_line=$current_history_line
        local this_command=`history 1 | awk '{print $2}'`;
        preexec "$this_command"
        # fi
    fi
}
trap '_invoke_exec' DEBUG

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


ST_START='\033k'
ST_STOP='\033\\'
if [ -z "$TERM_TITLE" ]; then
    TERM_TITLE="${HOSTNAME/.*/}"
fi

if [ "$_INTERACTIVE_MODE" ]; then
    echo "Terminal set to: [$TERM - $-]" 1>&2
    if ! _source $HOME/bin/termcolors; then
        echo "No terminal color file found. Terminal will be boring."
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



function get_job_str {
    if [ "$1" = "0" ]; then
        jobstr=""
    else
        jobstr=" [$1]"
    fi
    echo "$jobstr"
}

export HISTCMD
function pc {
    EXIT_STATUS=$?
    CHC=$(history 1)

    if [ "$TERM" == "screen" -a "$_INTERACTIVE_MODE" ]; then
        echo -ne "\033]0;${HOSTNAME}: ${PWD}\007" # Set window title for Gnome Terminal
    fi

    # Set PS1
    PS1_USER_COLOR="\[$cyan_ctrl\]"
    PS1_HOST_COLOR="\[$cyan_ctrl\]"
    PS1_JOBS_COLOR="\[$cyan_ctrl\]"
    PS1_PATH_COLOR="\[$cyan_ctrl\]"
    PS1_DOLLAR_COLOR="\[$cyan_ctrl\]"
    PS1_GIT_COLOR="\[$yellow_ctrl\]"
    PS1_RST="\[$reset_ctrl\]"

#    if [ "$LHC" = "$CHC" ]; then
#        PS1_EXIT_COLOR="$PS1_RST"
#        PS1_EXIT_MARK=" "
#    elif [ "$EXIT_STATUS" -eq 0 ]; then
    if [ "$EXIT_STATUS" -eq 0 ]; then
        PS1_EXIT_COLOR="\[$green_ctrl\]"
        PS1_EXIT_MARK="✓" # Check mark (\xE2\x9C\x93)
        # PS1_EXIT_MARK=">" # Check mark (\xE2\x9C\x93)
    else
        PS1_EXIT_COLOR="\[$red_ctrl\]"
        PS1_EXIT_MARK="✕" # X (\xE2\x9C\x95)
        # PS1_EXIT_MARK=">" # X (\xE2\x9C\x95)
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
        PS1+="\[${ST_START}${TERM_TITLE}"'$(get_job_str \j)'"${ST_STOP}\]"
    fi
    PS1+="${PS1_EXIT_COLOR}${PS1_EXIT_MARK}${PS1_RST} "
    PS1+="[${PS1_USER_COLOR}\u${PS1_RST}@$PS1_HOST_COLOR\h${PS1_RST}]-"
    PS1+="[${PS1_JOBS_COLOR}\j${PS1_RST}]-"
    PS1+="[${PS1_PATH_COLOR}\w${PS1_RST}]"
    PS1+="${PS1_GIT_COLOR}${PS1_GIT_INFO}${PS1_RST} "
    PS1+="${PS1_DOLLAR_COLOR}\$${PS1_RST} "
}
PROMPT_COMMAND="pc"


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

export EDITOR=vim
export DISPLAY=:0.0

# All
export FORCE_COLOR=1
export PATH=$HOME/bin:$PATH

case $platform in
    Linux)
        ;;
    BSD)
        ;;
    Darwin)
        ;;
    Windows)
        ;;
    Cygwin)
        ;;
esac
