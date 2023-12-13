#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/setup/utils.sh"

install_VLC() {
    print_in_purple "\n • Installing VLC \n\n"
    brew install vlc
}

install_python() {
    print_in_purple "\n • Installing python \n\n"
    brew install python
}

install_wget() {
    print_in_purple "\n • Installing wget \n\n"
    brew install wget
}

install_iterm() {
    print_in_purple "\n • Installing iterm2 \n\n"
    brew install iterm2
}

install_yq() {
    print_in_purple "\n • Installing yq \n\n"
    brew install yq
}

install_virtualbox() {
    print_in_purple "\n • Installing Virtual Box \n\n"
    brew install virtualbox
}

install_chrome() {
    print_in_purple "\n • Installing Chrome \n\n"
    brew install google-chrome-stable
}

install_helm() {
    print_in_purple "\n • Installing helm \n\n"
    brew install helm
}

install_htop() {
    print_in_purple "\n • Installing htop \n\n"
    brew install htop
}

install_nmap() {
    print_in_purple "\n • Installing nmap \n\n"
    brew install nmap
}

install_wireshark() {
    print_in_purple "\n • Installing wireshark \n\n"
    brew install wireshark
}

install_tor() {
    print_in_purple "\n • Installing tor \n\n"
    brew install tor
}

install_kubectl() {
    print_in_purple "\n • Installing kubectl \n\n"
    brew install kubectl
}

install_kubeshark() {
    print_in_purple "\n • Installing kubeshark \n\n"
    sh <(curl -Ls https://kubeshark.co/install)
}

install_random() {
    print_in_purple "\n • Installing everything else... \n\n"
    brew install \
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
    brew install terraform
}

install_ranger() {
    print_in_purple "\n • Installing ranger... \n\n"
    brew install ranger
}

install_neofetch() {
    print_in_purple "\n • Installing neofetch... \n\n"
    brew install neofetch
}

install_dhcpdump() {
    print_in_purple "\n • Installing dhcpdump... \n\n"
    brew install dhcpdump
}

install_thefuck() {
    print_in_purple "\n • Installing theFuck... \n\n"
    brew install thefuck
}

install_circumflex() {
    print_in_purple "\n • Installing circumflex... \n\n"
    brew install circumflex
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
    brew install man2html
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
