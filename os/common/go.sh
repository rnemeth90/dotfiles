#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/utils/utils.sh"

install_cobra() {
    print_in_green "\n • Installing cobra \n\n"
    go install github.com/spf13/cobra-cli@latest
}

main() {
    install_cobra
}

main
