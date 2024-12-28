#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    source "$DOT/utils/utils.sh"

check_npm() {
    if ! command -v npm &>/dev/null; then
        print_in_red "\n [✖] npm is not installed. Please install Node.js and npm first. \n"
        exit 1
    fi
}

install_npm_package() {
    local package=$1
    local is_global=${2:-false}

    print_in_green "\n • Installing $package... \n\n"

    if npm list -g "$package" &>/dev/null; then
        print_in_yellow "\n [✔] $package is already installed globally. Skipping...\n"
    elif [ "$is_global" = true ]; then
        if npm install -g "$package"; then
            print_in_green "\n [✔] Successfully installed $package globally!\n"
        else
            print_in_red "\n [✖] Failed to install $package globally.\n"
            exit 1
        fi
    else
        if npm install --save-dev --save-exact "$package"; then
            print_in_green "\n [✔] Successfully installed $package locally!\n"
        else
            print_in_red "\n [✖] Failed to install $package locally.\n"
            exit 1
        fi
    fi
}

main() {
    check_npm

    install_npm_package "azure-pipelines-language-server" true
    install_npm_package "tldr" true
    install_npm_package "prettier"
}

main
