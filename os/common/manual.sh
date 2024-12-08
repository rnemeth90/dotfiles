#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/utils/utils.sh"

install_kubeshark() {
    print_in_green "\n • Installing kubeshark \n\n"
    sh <(curl -Ls https://kubeshark.co/install)
}

install_golangci-lint() {
    # binary will be $(go env GOPATH)/bin/golangci-lint
    print_in_green "\n Installing golangci-lint  \n\n"
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.52.2
}

install_bash_completion() {
    print_in_green "\n Installing bash completion \n\n"
    /bin/bash -c "$(curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash)"
}

main() {
    install_kubeshark
    install_golangci-lint
}

main
