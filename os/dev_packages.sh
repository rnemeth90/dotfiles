#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/setup/utils.sh"

install_typescript() {
    print_in_purple "\n • Installing typescript globally\n\n"
    install_package typescript
}

install_az_cli() {
    print_in_purple "\n • Installing Azure Cli \n\n"
    install_package azure-cli
}

install_dotnet() {
    print_in_purple "\n • Installing dotnet \n\n"
    install_package dotnet-sdk
}

install_golang_and_friends() {
    print_in_purple "\n • Installing golang \n\n"
    install_package golang
    install_package hugo
    install_package gopls
    go install github.com/spf13/cobra-cli@latest
}

install_vim() {
    print_in_purple "\n • Installing vim \n\n"
    install_package neovim
}

install_powershell() {
    print_in_purple "\n • Installing tor \n\n"
    install_package powershell
}

install_docker() {
    print_in_purple "\n • Installing docker \n\n"
    install_package docker
}

install_VSCode() {
    print_in_purple "\n • Installing VSCode \n\n"
    install_package visual-studio-code
}

install_ghcli() {
    print_in_purple "\n • Installing github cli \n\n"
    install_package gh
}

install_az_pipeline_lsp() {
    print_in_purple "\n Installing Az Pipeline LSP \n\n"
    sudo npm install -g azure-pipelines-language-server

}

install_golangci-lint() {
    # binary will be $(go env GOPATH)/bin/golangci-lint
    print_in_purple "\n Installing golangci-lint  \n\n"
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.52.2
}

install_luarocks() {
    print_in_purple "\n Installing luarocks \n\n"
    install_package luarocks
}

install_ruby() {
    print_in_purple "\n Installing ruby \n\n"
    install_package rubygems
}

install_ripgrep() {
    print_in_purple "\n Installing ripgrep \n\n"
    install_package ripgrep
}

install_fd() {
    print_in_purple "\n Installing fd \n\n"
    install_package fd-find
}

install_php() {
    print_in_purple "\n Installing php \n\n"
    install_package php
}

install_java() {
    print_in_purple "\n Installing java \n\n"
    install_package openjdk@11
}

install_julia() {
    print_in_purple "\n Installing julia \n\n"
    install_package julia
}

install_prettier() {
    print_in_purple "\n Installing prettier \n\n"
    npm install --save-dev --save-exact prettier
}

install_black() {
    print_in_purple "\n Installing black \n\n"
    pip install black
}

install_stylua() {
    print_in_purple "\n Installing stylua \n\n"
    cargo install stylua
}

install_treesitter() {
    print_in_purple "\n Installing tree-sitter \n\n"
    cargo install tree-sitter-cli
}

install_nodejs() {
    print_in_purple "\n Installing nodejs \n\n"
    install_package node
}

main() {
    install_nodejs
    install_julia
    install_java
    install_php
    install_fd
    install_ripgrep
    install_ruby
    install_treesitter
    install_stylua
    install_golangci-lint
    install_az_pipeline_lsp
    install_nvm_node_yarn
    install_typescript
    install_prettier
    install_dotnet
    install_powershell
    install_VSCode
    install_vim
    install_golang_and_friends
    install_ghcli
}

main
