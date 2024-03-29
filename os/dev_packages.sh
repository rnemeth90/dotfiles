#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/setup/utils.sh"

install_brewfile() {
    print_in_purple "\n • Installing Brewfile from brew/Brewfile\n\n"
    # Making sure that brew is found
    brew bundle --file ~/dotfiles/brew/Brewfile
}

install_typescript() {
    print_in_purple "\n • Installing typescript globally\n\n"
    brew install typescript
}

install_az_cli() {
    print_in_purple "\n • Installing Azure Cli \n\n"
    brew install azure-cli
}

install_dotnet() {
    print_in_purple "\n • Installing dotnet \n\n"
    brew install dotnet-sdk
}

install_golang_and_friends() {
    print_in_purple "\n • Installing golang \n\n"
    brew install golang
    brew install hugo
    brew install gopls
    go install github.com/spf13/cobra-cli@latest
}

install_vim() {
    print_in_purple "\n • Installing vim \n\n"
    brew install neovim
}

install_powershell() {
    print_in_purple "\n • Installing tor \n\n"
    brew install powershell
}

install_docker() {
    print_in_purple "\n • Installing docker \n\n"
    brew install docker
}

install_VSCode() {
    print_in_purple "\n • Installing VSCode \n\n"
    brew install visual-studio-code
}

install_ghcli() {
    print_in_purple "\n • Installing github cli \n\n"
    brew install gh
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
    brew install luarocks
}

install_ruby() {
    print_in_purple "\n Installing ruby \n\n"
    brew install rubygems
}

install_ripgrep() {
    print_in_purple "\n Installing ripgrep \n\n"
    brew install ripgrep
}

install_fd() {
    print_in_purple "\n Installing fd \n\n"
    brew install fd-find
}

install_php() {
    print_in_purple "\n Installing php \n\n"
    brew install php
}

install_java() {
    print_in_purple "\n Installing java \n\n"
    brew install openjdk@11
}

install_julia() {
    print_in_purple "\n Installing julia \n\n"
    brew install julia
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
    brew install node
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
    install_brewfile
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
