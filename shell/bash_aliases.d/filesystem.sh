#!/usr/bin/env bash

alias dusingle="sudo du -sh"            # size of directory
alias duall="sudo du -hd 1 . | sort -h" # size of subdirectories (1st level)
alias dfall="sudo df -h 1 .  | sort -h" # available space

alias chmodcode="stat --format '%a'"

# find symlinks in current directory
function findln() {
    find . -type l -exec readlink -nf {} ';' -exec echo " -> {}" ';' | grep "$*"
}

# find broken symlinks in current directory
alias brokenln="find . -type l -exec test ! -e {} \; -print"