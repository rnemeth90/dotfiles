#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    source "$DOT/utils/utils.sh"

install_tldr() {
    print_in_green "\n • Installing tldr... \n\n"
    npm install -g tldr
}

install_az_pipeline_lsp() {
    print_in_green "\n Installing Az Pipeline LSP \n\n"
    sudo npm install -g azure-pipelines-language-server
}

install_prettier() {
    print_in_green "\n Installing prettier \n\n"
    npm install --save-dev --save-exact prettier
}

main() {
    install_az_pipeline_lsp
    install_tldr
    install_prettier
}

main
