#!/usr/bin/env bash

# docker aliases
alias d=docker
alias di='docker images'
alias prune='docker system prune'
alias pruneall='docker system prune --all --force'
alias dst='docker container ls -a && docker images -a && docker ps'

# docker compose
alias dcud='docker-compose up -d'
alias dcd='docker-compose down'
