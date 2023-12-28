#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/setup/utils.sh"

install_VLC() {
    print_in_purple "\n • Installing VLC \n\n"
    sudo apt -y install vlc
}

install_python() {
    print_in_purple "\n • Installing python \n\n"
    sudo apt -y install python
}

install_wget() {
    print_in_purple "\n • Installing wget \n\n"
    sudo apt -y install wget
}

install_iterm() {
    print_in_purple "\n • Installing iterm2 \n\n"
    sudo apt -y install iterm2
}

install_yq() {
    print_in_purple "\n • Installing yq \n\n"
    sudo apt -y install yq
}

install_virtualbox() {
    print_in_purple "\n • Installing Virtual Box \n\n"
    sudo apt -y install virtualbox
}

install_chrome() {
    print_in_purple "\n • Installing Chrome \n\n"
    sudo apt -y install google-chrome-stable
}

install_helm() {
    print_in_purple "\n • Installing helm \n\n"
    sudo apt -y install helm
}

install_htop() {
    print_in_purple "\n • Installing htop \n\n"
    sudo apt -y install htop
}

install_nmap() {
    print_in_purple "\n • Installing nmap \n\n"
    sudo apt -y install nmap
}

install_wireshark() {
    print_in_purple "\n • Installing wireshark \n\n"
    sudo apt -y install wireshark
}

install_tor() {
    print_in_purple "\n • Installing tor \n\n"
    sudo apt -y install tor
}

install_kubectl() {
    print_in_purple "\n • Installing kubectl \n\n"
    sudo apt -y install kubectl
}

install_kubeshark() {
    print_in_purple "\n • Installing kubeshark \n\n"
    sh <(curl -Ls https://kubeshark.co/install)
}

install_random() {
    print_in_purple "\n • Installing everything else... \n\n"
    sudo apt -y install \
        bash-completion \
        figlet \
        gnupg \
        jq \
        kubetail \
        kubecolor \
        nmap \
        neofetch \
        ranger \
        speedtest-cli
}

install_terraform() {
    print_in_purple "\n • Installing terraform... \n\n"
    sudo apt -y install terraform
}

install_ranger() {
    print_in_purple "\n • Installing ranger... \n\n"
    sudo apt -y install ranger
}

install_neofetch() {
    print_in_purple "\n • Installing neofetch... \n\n"
    sudo apt -y install neofetch
}

install_dhcpdump() {
    print_in_purple "\n • Installing dhcpdump... \n\n"
    sudo apt -y install dhcpdump
}

install_thefuck() {
    print_in_purple "\n • Installing theFuck... \n\n"
    sudo apt -y install thefuck
}

install_circumflex() {
    print_in_purple "\n • Installing circumflex... \n\n"
    sudo apt -y install circumflex
}

install_tldr() {
    print_in_purple "\n • Installing tldr... \n\n"
    npm install -g tldr
}

install_vivid() {
    print_in_purple "\n • Installing vivid... \n\n"
    cargo install vivid
}

install_man2html() {
    print_in_purple "\n • Installing man2html... \n\n"
    sudo apt -y install man2html
}

main() {
    install_python
    install_wget
    install_VLC
    install_chrome
    install_dhcpdump
    install_helm
    install_htop
    install_kubectl
    install_mizu
    install_random
    install_man2html
    install_ranger
    install_iterm
    install_virtualbox
    install_wireshark
    install_nmap
    install_tor
    install_thefuck
    install_circumflex
    install_tldr
    install_yq
}

main
