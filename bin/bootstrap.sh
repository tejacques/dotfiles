#!/bin/bash

# GLOB IGNORE
GLOBIGNORE='.:..'

# Logging stuff.
function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;33m➜\033[0m  $@"; }

function backup_file() {
    local base=$1
    local dest=$2
    e_arrow "Backing up ~/$base."
    # Set backup flag, so a nice message can be shown at the end.
    backup=1
    # Create backup dir if it doesn't already exist.
    if [[ -ne "$backup_dir" ]]
    then
        e_arrow "Making backup directory: $backup_dir"
        mkdir -p "$backup_dir"
    fi
    # Backup file / link / whatever.
    echo mv "$dest" "$backup_dir"
    mv "$dest" "$backup_dir"
}

function copy_file() {
    local base=$1
    local dest=$2
    e_success "Copying ~/$base"
    echo cp "$dest" ~/
    cp "$dest" ~/
}

function link_file() {
    local base=$1
    local dest=$2
    e_success "Linking ~/$base"
    echo ln -sf ${dest#$HOME/} ~/
    ln -sf ${dest#$HOME/} ~/
}

function do_stuff() {
    local base dest
    local cmd=$1
    local dir=$2
    local files=(~/dotfiles/$dir/*)
    local files2=~/dotfiles/$dir

    echo files: $files
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
echo 'do_stuff "copy" "copy"'
do_stuff "copy" "copy"


echo ""
echo ""
echo 'do_stuff "link" "link"'
do_stuff "link" "link"


# Finished
e_header "Done!"
