#!/usr/bin/env bash

alias gstatus='git status'
alias g=git
alias git-yolo='git commit -am $(curl -s http://whatthecommit.com/index.txt)'
alias gb='git branch'
alias gad='git add .'
alias gcheckout='git checkout -b'
alias gclone='git clone'
alias gpull='git pull'
alias gd='git diff'
alias gb='git branch'
alias gpush='git push'
alias gs='git status -sb'
alias gf='git fetch --prune'
alias grevertlast='git reset --soft HEAD~1'
alias glog='git log --oneline --pretty=format:"%C(yellow)%h%C(reset)%x09%C(magenta)%an%C(reset)%x09%C(yellow)%ad%C(reset)%x09%s"'
