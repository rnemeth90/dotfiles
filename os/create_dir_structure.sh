#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  source "$DOT/utils/utils.sh"

create_repo_dir() {
  if [ ! -e "$HOME/repos" ]; then
    echo "Creating $HOME/repos ..."
    sudo mkdir $HOME/repos && sudo chown -R $(whoami): $HOME/repos
  fi
}

main() {
  print_in_purple "\n • Create directory structure\n\n"
  create_repo_dir
}

