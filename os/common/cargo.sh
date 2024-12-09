#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/utils/utils.sh"

check_cargo() {
    if ! command -v cargo &>/dev/null; then
        print_in_red "\n [✖] cargo is not installed. Please install Rust and cargo first. \n"
        exit 1
    fi
}

install_cargo_package() {
    local package=$1

    print_in_green "\n • Installing $package... \n\n"

    if cargo install --list | grep -q "$package"; then
        print_in_yellow "\n [✔] $package is already installed. Skipping...\n"
    else
        if cargo install "$package"; then
            print_in_green "\n [✔] Successfully installed $package!\n"
        else
            print_in_red "\n [✖] Failed to install $package.\n"
            exit 1
        fi
    fi
}

main() {
    check_cargo

    packages=(
        vivid
        stylua
        tree-sitter-cli
    )

    for package in "${packages[@]}"; do
        install_cargo_package "$package"
    done
}

main
