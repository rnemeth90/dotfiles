#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_snap() {
    print_in_purple "\n • Installing snap\n\n"
    sudo brew install snapd
    sudo ln -s /var/lib/snapd/snap /snap
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_homebrew() {
    print_in_purple "\n • Installing Homebrew \n\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_nvm_node_yarn() {
    print_in_purple "\n • Installing nvm, node and yarn. Use node LTS as default.\n\n"
    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    source ~/.bashrc
    nvm install --lts
    nvm use --lts
    source ~/.bashrc
    npm install --global yarn
}

install_npm() {
    print_in_purple "\n • Installing npm \n\n"
    sudo brew install npm
}

install_cargo() {
    print_in_purple "\n Installing cargo  \n\n"
    curl https://sh.rustup.rs -sSf | sh -s -- -y
}

main() {
    install_homebrew
    install_npm
    install_snap
    install_nvm_node_yarn
    install_cargo
}

main
