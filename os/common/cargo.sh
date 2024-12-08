#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/utils/utils.sh"

install_vivid() {
    print_in_green "\n • Installing vivid... \n\n"
    cargo install vivid
}

install_stylua() {
    print_in_green "\n Installing stylua \n\n"
    cargo install stylua
}

install_treesitter() {
    print_in_green "\n Installing tree-sitter \n\n"
    cargo install tree-sitter-cli
}

main() {
    install_vivid
    install_stylua
    install_treesitter
}

main


