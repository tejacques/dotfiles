#!/bin/bash

# GLOB IGNORE
GLOBIGNORE='.:..'

# Logging stuff.
function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;33m➜\033[0m  $@"; }

function setup_bin() {
    BINDIR="$HOME/bin"
    e_arrow "Checking $BINDIR"
    if [[ ! -e "$BINDIR" ]]
    then
        e_arrow mkdir -p "$BINDIR"
        mkdir -p "$BINDIR"
        e_arrow chmod +x $BINDIR
        chmod +x $BINDIR
    fi
    if [[ ! -e "$BINDIR" ]]
    then
        e_error "Error: bin directory not created"
    fi
}

function backup_file() {
    local base=$1
    local dest=$2
    local msg="cp $dest $backup_dir"
    e_arrow "Backing up ~/$base."
    # Set backup flag, so a nice message can be shown at the end.
    backup=1
    # Create backup dir if it doesn't already exist.
    if [[ ! -e "$backup_dir" ]]
    then
        e_arrow "Making backup directory: $backup_dir"
        mkdir -p "$backup_dir"
    fi
    if [[ ! -e "$backup_dir" ]]
    then
        e_error "Error backup directory not created"
    fi
    # Backup file / link / whatever.
    if cp -r "$dest" "$backup_dir"
    then
        e_success $msg
    elif
        e_error $msg
    fi
}

function copy_file() {
    local base=$1
    local dest=$2
    local msg="cp -r $dest ~/"
    if cp -r "$dest" ~/
    then
        e_success $msg
    elif
        e_error $msg
    fi
}

function link_file() {
    local base=$1
    local dest=$2
    local msg="echo ln -sf ${dest#$HOME/} ~/"
    
    if ln -sf ${dest#$HOME/} ~/
    then
        e_success $msg
    elif
        e_error $msg
    fi
}

function do_stuff() {
    local base dest
    local cmd=$1
    local dir=$2
    local files=(~/dotfiles/$dir/*)

    if (( ${#files[@]} == 0 )); then return; fi

    for file in "${files[@]}"; do
        echo ""
        base="$(basename $file)"
        dest="$HOME/$base"

        echo file $file
        echo base $base
        echo dest $dest

        # Destination file already exists in ~/. Back it up!
        if [[ -e "$dest" ]]; then
            backup_file "$base" "$dest"
        fi

        "$cmd""_file" "$base" "$file"
    done
}

# backup_base="$HOME/dotfiles/backups"
backup_dir="$HOME/dotfiles/backups/$(date "+%Y_%m_%d-%H_%M_%S")/"

echo ""
echo ""

#setup_bin

echo '=============================='
echo 'do_stuff "copy" "copy"'
echo '=============================='
do_stuff "copy" "copy"


echo ""
echo ""
echo '=============================='
echo 'do_stuff "link" "link"'
echo '=============================='
do_stuff "link" "link"


# Finished
e_header "Done!"
