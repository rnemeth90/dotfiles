#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_VSCode() {
  print_in_purple "\n • Installing VSCode \n\n"
  sudo apt-get install wget gpg
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg
  sudo apt install apt-transport-https
  sudo apt update
  sudo apt install code -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_VLC() {
  print_in_purple "\n • Installing VLC \n\n"
  sudo apt install -y vlc
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_terminator() {
  print_in_purple "\n • Installing terminator \n\n"
  sudo apt install -y terminator
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_docker() {
  print_in_purple "\n • Installing docker \n\n"
  sudo apt install -y docker
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_mutt() {
  print_in_purple "\n • Installing mutt \n\n"
  sudo apt install -y mutt
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_virtualbox() {
  print_in_purple "\n • Installing Virtual Box \n\n"
  sudo apt install -y virtualbox
}

# - - - - - - - - - - - - - - - - - - - - -   - - - - - - - - - - - - - -

install_chrome() {
  print_in_purple "\n • Installing Chrome \n\n"
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo add-apt-repository "deb http://dl.google.com/linux/chrome/deb/ stable main"
  sudo apt update
  sudo apt install google-chrome-stable -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_brave() {
  print_in_purple "\n • Installing Brave \n\n"
  sudo apt install curl
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install brave-browser -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_helm() {
  print_in_purple "\n • Installing helm \n\n"
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
  sudo apt-get install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_htop() {
  print_in_purple "\n • Installing htop \n\n"
  sudo apt install htop -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_nmap() {
  print_in_purple "\n • Installing nmap \n\n"
  sudo apt install nmap -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_wireshark() {
  print_in_purple "\n • Installing wireshark \n\n"
  sudo apt install wireshark -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_powertop() {
  print_in_purple "\n • Installing powertop \n\n"
  sudo apt install powertop -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_tor() {
  print_in_purple "\n • Installing tor \n\n"
  sudo apt install tor -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_powershell() {
  print_in_purple "\n • Installing tor \n\n"
  sudo apt update  && sudo apt install -y curl gnupg apt-transport-https
  curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'
  sudo apt update && sudo apt install -y powershell
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_kubectl() {
  print_in_purple "\n • Installing kubectl \n\n"
  sudo apt-get install -y ca-certificates curl
  sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_kubeshark() {
  print_in_purple "\n • Installing kubeshark \n\n"
  sh <(curl -Ls https://kubeshark.co/install)
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
    golang \
    jq \
    kubetail \
    kubecolor \
    nmap \
    neofetch \
    net-tools \
    nfs-common \
    nodejs \
    python3-pip \
    ranger \
    software-properties-common \
    speedtest-cli \
    wapiti
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
  sudo apt install plank -y
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

  install_VSCode

  install_VLC

  install_ulauncher

  install_chrome

  install_brave

  install_dhcpdump

  install_docker

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

  install_1password

  install_powershell

  install_plank
}

main
