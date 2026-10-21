#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    source "$DOT/utils/utils.sh"

install_yay() {
    if [[ ! -f /etc/arch-release ]]; then
        print_in_yellow "\n • Skipping yay (not Arch Linux).\n\n"
        return
    fi

    if command -v yay >/dev/null 2>&1; then
        print_in_green "\n • yay is already installed. Skipping...\n\n"
        return
    fi

    print_in_purple "\n • Installing yay \n\n"

    if ! sudo pacman -S --needed --noconfirm base-devel git; then
        print_in_yellow "\n • Could not install yay build prerequisites.\n\n"
        return 1
    fi

    if [[ ! -d ~/repos/aur.archlinux.org/yay-bin ]]; then
        mkdir -p ~/repos/aur.archlinux.org/ || return 1
        git clone https://aur.archlinux.org/yay-bin.git ~/repos/aur.archlinux.org/yay-bin || return 1
    fi

    if [[ ! -f ~/repos/aur.archlinux.org/yay-bin/PKGBUILD ]]; then
        print_in_yellow "\n • yay source checkout is missing its PKGBUILD.\n\n"
        return 1
    fi

    if ! (cd ~/repos/aur.archlinux.org/yay-bin && makepkg -si --noconfirm); then
        print_in_yellow "\n • Failed to build or install yay.\n\n"
        return 1
    fi

    command -v yay >/dev/null 2>&1
}

install_homebrew() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_in_yellow "\n • Skipping Homebrew (not macOS).\n\n"
        return
    fi

    if ! command -v brew >/dev/null 2>&1; then
        print_in_purple "\n • Installing Homebrew \n\n"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        print_in_green "\n • Homebrew is already installed. Skipping...\n\n"
    fi
}

# install_nvm_node_yarn() {
#     if ! command -v nvm >/dev/null 2>&1; then
#         print_in_purple "\n • Installing NVM, Node.js, and Yarn. Setting Node LTS as default.\n\n"
#         curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
#         source ~/.bashrc
#         nvm install --lts
#         nvm use --lts
#         npm install --global yarn
#     else
#         print_in_green "\n • NVM is already installed. Skipping...\n\n"
#     fi
# }

install_npm() {
    if ! command -v npm >/dev/null 2>&1; then
        print_in_purple "\n • Installing npm \n\n"
        if command -v brew >/dev/null 2>&1; then
            brew install npm
        else
            print_in_yellow "\n • brew not available, skipping npm install via brew.\n\n"
        fi
    else
        print_in_green "\n • npm is already installed. Skipping...\n\n"
    fi
}

install_cargo() {
    if ! command -v cargo >/dev/null 2>&1; then
        print_in_purple "\n • Installing Rust and Cargo \n\n"
        curl https://sh.rustup.rs -sSf | sh -s -- -y
    else
        print_in_green "\n • Cargo is already installed. Skipping...\n\n"
    fi
}

main() {
    install_homebrew
    if [[ -f /etc/arch-release ]]; then
        install_yay || return 1
    fi
    # install_npm
    # install_nvm_node_yarn
    # install_cargo

    print_in_green "\n • All installations completed successfully! \n\n"
}

main
