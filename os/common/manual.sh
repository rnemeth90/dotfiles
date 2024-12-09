#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/utils/utils.sh"

check_command() {
    if ! command -v "$1" &>/dev/null; then
        print_in_red "\n [✖] $1 is not installed. Please install it first. \n"
        exit 1
    fi
}

install_kubeshark() {
    print_in_green "\n • Installing kubeshark \n\n"
    if command -v kubeshark &>/dev/null; then
        print_in_yellow "\n [✔] kubeshark is already installed. Skipping...\n"
    else
        if sh <(curl -Ls https://kubeshark.co/install); then
            print_in_green "\n [✔] Successfully installed kubeshark.\n"
        else
            print_in_red "\n [✖] Failed to install kubeshark.\n"
            exit 1
        fi
    fi
}

install_golangci_lint() {
    print_in_green "\n • Installing golangci-lint \n\n"
    local golangci_bin
    golangci_bin="$(go env GOPATH)/bin/golangci-lint"

    if [[ -x "$golangci_bin" ]]; then
        print_in_yellow "\n [✔] golangci-lint is already installed. Skipping...\n"
    else
        if curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin" v1.52.2; then
            print_in_green "\n [✔] Successfully installed golangci-lint.\n"
        else
            print_in_red "\n [✖] Failed to install golangci-lint.\n"
            exit 1
        fi
    fi
}

install_bash_completion() {
    print_in_green "\n • Installing bash completion for Git \n\n"
    local git_completion="$HOME/.git-completion.bash"

    if [[ -f "$git_completion" ]]; then
        print_in_yellow "\n [✔] Git bash completion is already installed. Skipping...\n"
    else
        if curl -o "$git_completion" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash; then
            echo "[ -f ~/.git-completion.bash ] && . ~/.git-completion.bash" >>"$HOME/.bashrc"
            print_in_green "\n [✔] Successfully installed Git bash completion.\n"
        else
            print_in_red "\n [✖] Failed to install Git bash completion.\n"
            exit 1
        fi
    fi
}

main() {
    check_command "curl"
    check_command "sh"
    check_command "go"

    install_kubeshark
    install_golangci_lint
    install_bash_completion
}

main
