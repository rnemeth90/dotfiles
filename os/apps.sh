#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/setup/utils.sh"

install_1password() {
  print_in_purple "\n • Installing 1password \n\n"
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
  sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
  curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
  sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
  curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
  sudo apt update && sudo apt install 1password
}

install_VLC() {
  print_in_purple "\n • Installing VLC \n\n"
  sudo apt install -y vlc
}

install_terminator() {
  print_in_purple "\n • Installing terminator \n\n"
  sudo apt install -y terminator
  pip install requests
  mkdir -p $HOME/.config/terminator/plugins
  wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py"
}

install_yq(){
  print_in_purple "\n • Installing yq \n\n"
  sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq
  sudo chmod +x /usr/bin/yq
}

install_mutt() {
  print_in_purple "\n • Installing mutt \n\n"
  sudo apt install -y mutt
}

install_virtualbox() {
  print_in_purple "\n • Installing Virtual Box \n\n"
  sudo apt install -y virtualbox
}

install_chrome() {
  print_in_purple "\n • Installing Chrome \n\n"
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo add-apt-repository "deb http://dl.google.com/linux/chrome/deb/ stable main"
  sudo apt update
  sudo apt install google-chrome-stable -y
}

install_brave() {
  print_in_purple "\n • Installing Brave \n\n"
  sudo apt install curl
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install brave-browser -y
}

install_helm() {
  print_in_purple "\n • Installing helm \n\n"
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
  sudo apt-get install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm -y
}

install_htop() {
  print_in_purple "\n • Installing htop \n\n"
  sudo apt install htop -y
}

install_nmap() {
  print_in_purple "\n • Installing nmap \n\n"
  sudo apt install nmap -y
}

install_wireshark() {
  print_in_purple "\n • Installing wireshark \n\n"
  sudo apt install wireshark -y
}

install_powertop() {
  print_in_purple "\n • Installing powertop \n\n"
  sudo apt install powertop -y
}

install_tor() {
  print_in_purple "\n • Installing tor \n\n"
  sudo apt install tor -y
}

install_kubectl() {
  print_in_purple "\n • Installing kubectl \n\n"
  sudo apt-get install -y ca-certificates curl
  sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl
}

install_kubeshark() {
  print_in_purple "\n • Installing kubeshark \n\n"
  sh <(curl -Ls https://kubeshark.co/install)
}

install_random() {
  print_in_purple "\n • Installing everything else... \n\n"
  sudo apt install -y \
    apt-transport-https \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    dnsenum \
    figlet \
    file \
    gnupg \
    jq \
    kubetail \
    kubecolor \
    nmap \
    neofetch \
    net-tools \
    nfs-common \
    python3-pip \
    ranger \
    software-properties-common \
    speedtest-cli \
    wapiti \
    font-manager \
    playerctl \
    lxappearance
}

install_terraform() {
  print_in_purple "\n • Installing terraform... \n\n"
  sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
  wget -O- https://apt.releases.hashicorp.com/gpg |
    gpg --dearmor |
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
  sudo apt-get install terraform -y
}

install_ranger() {
  print_in_purple "\n • Installing ranger... \n\n"
  sudo apt install ranger -y
}

install_neofetch() {
  print_in_purple "\n • Installing neofetch... \n\n"
  sudo apt install neofetch -y
}

install_dhcpdump() {
  print_in_purple "\n • Installing dhcpdump... \n\n"
  sudo apt install dhcpdump -y
}

install_plank() {
  print_in_purple "\n • Installing plank... \n\n"
  sudo apt update -y
  sudo apt install plank -y
}

install_thefuck() {
  print_in_purple "\n • Installing theFuck... \n\n"
  sudo apt update -y
  sudo apt install python3-dev python3-pip python3-setuptools
  sudo pip3 install thefuck
}

install_stacer() {
  print_in_purple "\n • Installing stacer... \n\n"
  sudo apt update -y
  sudo apt install stacer -y
}

install_circumflex() {
  print_in_purple "\n • Installing circumflex... \n\n"
  brew install circumflex
}

install_alpine() {
  print_in_purple "\n • Installing alpine mail client... \n\n"
  sudo apt install alpine -y
}

install_tldr() {
  print_in_purple "\n • Installing tldr... \n\n"
  sudo npm install -g tldr
}

install_i3() {
  print_in_purple "\n • Installing i3... \n\n"
  # i3 4.22 is not yet in the debian/mint repos
  curl https://baltocdn.com/i3-window-manager/signing.asc | sudo apt-key add -
  sudo apt install apt-transport-https --yes
  echo "deb https://baltocdn.com/i3-window-manager/i3/i3-autobuild-ubuntu/ all main" | sudo tee /etc/apt/sources.list.d/i3-autobuild.list
  sudo apt update -y
  sudo apt install i3 i3lock xautolock rofi -y
}

install_polybar() {
  print_in_purple "\n • Installing polybar... \n\n"
  sudo apt install polybar -y
}

install_feh() {
  print_in_purple "\n • Installing feh... \n\n"
  sudo apt install feh -y
}

install_mpd() {
  print_in_purple "\n • Installing mpd... \n\n"
  sudo apt install mpd -y
}

main() {
  install_mpd
  install_i3
  install_VLC
  install_chrome
  install_brave
  install_dhcpdump
  install_helm
  install_htop
  install_kubectl
  install_mizu
  install_mutt
  install_random
  install_ranger
  install_terminator
  # install_terraform
  install_virtualbox
  install_wireshark
  install_nmap
  install_tor
  install_powertop
  #install_1password
  install_plank
  install_thefuck
  install_circumflex
  install_alpine
  install_tldr
  install_yq
}

main
