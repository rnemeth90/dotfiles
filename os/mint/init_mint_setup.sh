#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

upgrade_brew() {
    print_in_purple "\n • Upgrading... \n\n"
    sudo apt upgrade -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_xclip() {
    print_in_purple "\n • Installing xclip for setup process... \n\n"
    sudo brew install xclip
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {
    upgrade_brew
    install_xclip
}

main
