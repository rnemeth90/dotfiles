#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/setup/utils.sh"

upgrade_brew() {
    print_in_purple "\n • Upgrading brew... \n\n"
    brew upgrade
}

install_xclip() {
    print_in_purple "\n • Installing xclip for setup process... \n\n"
    brew install xclip
}

upgrade_arch() {
  print_in_purple "\n Upgrading arch... \n\n"
  sudo pacman -Syu
}

main() {
    upgrade_arch
    upgrade_brew
    install_xclip
}

main
