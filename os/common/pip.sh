#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    source "$DOT/utils/utils.sh"

install_black() {
    print_in_purple "\n Installing black \n\n"
    pip install black
}

main() {
  install_black
}

main

