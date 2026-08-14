#!/usr/bin/env bash

alias g='git'
alias gs='git status -sb'
alias gstatus='git status'
alias gb='git branch'
alias gd='git diff'
alias gdc='git diff --cached'
alias gad='git add -p'          # interactive staging (safer than add .)
alias gadd='git add .'          # stage everything (use intentionally)
alias gcheckout='git checkout -b'
alias gco='git checkout'
alias gclone='git clone'
alias gpull='git pull'
alias gpush='git push'
alias gpushf='git push --force-with-lease'
alias gf='git fetch --prune'
alias grevertlast='git reset --soft HEAD~1'
alias glog='git log --oneline --pretty=format:"%C(yellow)%h%C(reset)%x09%C(magenta)%an%C(reset)%x09%C(yellow)%ad%C(reset)%x09%s"'
alias glogg='git log --oneline --graph --decorate --all'
alias gstash='git stash'
alias gstashp='git stash pop'
alias gstashl='git stash list'

# WIP — save and restore work-in-progress
alias gwip='git add -A && git commit -m "WIP: work in progress [skip ci]"'
alias gunwip='git log -1 --pretty=%s | grep -q "WIP" && git reset HEAD~1'

alias git-yolo='git commit -am $(curl -s http://whatthecommit.com/index.txt)'
