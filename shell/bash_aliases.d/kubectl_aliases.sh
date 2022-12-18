#!/bin/bash

alias k=kubecolor
alias kgp='k get pods -o wide'
alias kgn='k get ns'
alias kgs='k get svc'
alias kn='k config set-context --current --namespace'
export KUBE_EDITOR=nano
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"