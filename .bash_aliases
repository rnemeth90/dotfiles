# Make some possibly destructive commands more interactive.
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias python=python3
alias nano='nano -ET2'

# Add some easy shortcuts for formatted directory listings and add a touch of color.
alias ll='ls -lF --color=auto'
alias la='ls -alF --color=auto'
alias ls='ls -F'

# Make grep more user friendly by highlighting matches
# and exclude grepping through .svn folders.
alias grep='grep --color=auto --exclude-dir=\.svn'

# Shortcut for using the Kdiff3 tool for svn diffs.
alias svnkdiff3='svn diff --diff-cmd kdiff3'

# Git aliases
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

# Kubectl aliases

alias k=kubecolor
alias kgp='k get pods -o wide'
alias kgn='k get ns'
alias kgs='k get svc'
alias kn='k config set-context --current --namespace'
export KUBE_EDITOR=nano

# terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tfp='terraform plan'

# docker aliases
alias d=docker
alias di='docker images'
alias prune='docker system prune'
alias pruneall='docker system prune --all --force'
alias dst='docker container ls -a && docker images -a && docker ps'
alias docker='/opt/docker/docker'
export DOCKER_HOST=tcp://localhost:2375

# docker compose
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'

# az aliases
alias azsubs='az account list -o table'
alias azprod='az account set -s production'
alias aznonprod='az account set -s non-production'
alias aztraining='az account set -s "internal training"'

# helm aliases


# work related aliases

alias aksprodeu='kubectl config use-context prod-02eu2-01-aks'
alias aksprodau='kubectl config use-context prod-02au1-01-aks'
alias aksprodus='kubectl config use-context prod-02us1-01-aks'
alias aksrc='kubectl config use-context rc-02us1-01-aks'
alias akslabs='kubectl config use-context lab-02us1-01-aks'
alias aksmylab='kubectl config use-context rnemeth-k8s-cl-01'
alias akshomelab='kubectl config use-context homelab'
