#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/utils/utils.sh"

check_go() {
    if ! command -v go &>/dev/null; then
        print_in_red "\n [✖] Go is not installed. Please install Go first. \n"
        exit 1
    fi
}

install_go_tool() {
    local package=$1
    local binary_name=$2

    print_in_green "\n • Installing $binary_name \n\n"

    if command -v "$binary_name" &>/dev/null; then
        print_in_yellow "\n [✔] $binary_name is already installed. Skipping...\n"
    else
        if go install "$package"; then
            print_in_green "\n [✔] Successfully installed $binary_name!\n"
        else
            print_in_red "\n [✖] Failed to install $binary_name.\n"
            exit 1
        fi
    fi
}

main() {
    check_go

    install_go_tool "github.com/spf13/cobra-cli@latest" "cobra-cli"
}

main
