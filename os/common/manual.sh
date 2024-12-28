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

install_google_chrome() {
    print_in_green "\n • Installing Google Chrome \n\n"
    if command -v google-chrome &>/dev/null; then
        print_in_yellow "\n [✔] Google Chrome is already installed. Skipping...\n"
    else
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apt install ./google-chrome-stable_current_amd64.deb -y
        rm google-chrome-stable_current_amd64.deb
        print_in_green "\n [✔] Successfully installed Google Chrome.\n"
    fi
}

install_azure_cli() {
    print_in_green "\n • Installing Azure CLI \n\n"
    if command -v az &>/dev/null; then
        print_in_yellow "\n [✔] Azure CLI is already installed. Skipping...\n"
    else
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        print_in_green "\n [✔] Successfully installed Azure CLI.\n"
    fi
}

install_nodejs_and_typescript() {
    print_in_green "\n • Installing Node.js and TypeScript \n\n"
    if command -v node &>/dev/null; then
        print_in_yellow "\n [✔] Node.js is already installed. Skipping...\n"
    else
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt install -y nodejs
        print_in_green "\n [✔] Successfully installed Node.js.\n"
    fi

    if command -v tsc &>/dev/null; then
        print_in_yellow "\n [✔] TypeScript is already installed. Skipping...\n"
    else
        sudo npm install -g typescript
        print_in_green "\n [✔] Successfully installed TypeScript.\n"
    fi
}

install_vscode() {
    print_in_green "\n • Installing Visual Studio Code \n\n"
    if command -v code &>/dev/null; then
        print_in_yellow "\n [✔] Visual Studio Code is already installed. Skipping...\n"
    else
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt update
        sudo apt install code -y
        rm packages.microsoft.gpg
        print_in_green "\n [✔] Successfully installed Visual Studio Code.\n"
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

install_yq() {
    print_in_green "\n • Installing yq \n\n"
    if command -v yq &>/dev/null; then
        print_in_yellow "\n [✔] yq is already installed. Skipping...\n"
    else
        sudo snap install yq
        print_in_green "\n [✔] Successfully installed yq.\n"
    fi
}

install_terraform() {
    print_in_green "\n • Installing Terraform \n\n"
    if command -v terraform &>/dev/null; then
        print_in_yellow "\n [✔] Terraform is already installed. Skipping...\n"
    else
        sudo snap install terraform --classic
        print_in_green "\n [✔] Successfully installed Terraform.\n"
    fi
}

install_speedtest() {
    print_in_green "\n • Installing Speedtest-cli \n\n"
    if command -v speedtest &>/dev/null; then
      curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
      sudo apt-get install speedtest
    else
        print_in_green "\n [✔] Speedtest-cli already installed.\n"
    fi
}

main() {
    check_command "curl"
    check_command "sh"
    check_command "go"

    install_google_chrome
    install_azure_cli
    install_nodejs_and_typescript
    install_vscode
    install_kubeshark
    install_golangci_lint
    install_yq
    install_terraform
    install_speedtest
}

main

