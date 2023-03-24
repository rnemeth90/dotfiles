#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_brewfile() {
  print_in_purple "\n • Installing Brewfile from brew/Brewfile\n\n"
  # Making sure that brew is found
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  brew bundle --file ~/dotfiles/brew/Brewfile
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_and_setup_postgres() {
  print_in_purple "\n • Installing and setting up postgres\n\n"
  # Install, init db, enable and start service
  sudo apt install -y postgresql postgresql-contrib
  sudo /usr/bin/postgresql-setup --initdb
  sudo systemctl enable postgresql
  sudo systemctl start postgresql
  print_in_yellow "\n Creating postgres superuser with name: $USER\n\n"
  print_in_yellow "\nType in your postgres superuser password:\n"
  read POSTGRESPWD
  sudo su - postgres bash -c "psql -c \"CREATE ROLE $USER LOGIN SUPERUSER PASSWORD '$POSTGRESPWD';\""
  sudo su - postgres bash -c "psql -c \"CREATE DATABASE $USER;\""
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

nvm_node_yarn() {
  print_in_purple "\n • Installing nvm, node and yarn. Use node LTS as default.\n\n"
  curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
  source ~/.bashrc
  nvm install --lts
  nvm use --lts
  source ~/.bashrc
  npm install --global yarn
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_typescript() {
  print_in_purple "\n • Installing typescript globally\n\n"
  sudo apt install -y node-typescript
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_az_cli() {
  print_in_purple "\n • Installing Azure Cli \n\n"

  echo "deb http://security.ubuntu.com/ubuntu focal-security main" | sudo tee /etc/apt/sources.list.d/focal-security.list
  sudo apt-get update
  sudo apt-get install libssl1.1

  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bionic main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
  sudo apt update
  sudo apt install azure-cli

  sudo rm -rf /etc/apt/sources.list.d/focal-security.list

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_dotnet() {
  print_in_purple "\n • Installing dotnet \n\n"
  wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  sudo rm -rf packages-microsoft-prod.deb
  sudo apt-get update && sudo apt-get install -y dotnet-sdk-7.0
  sudo apt-get update && sudo apt-get install -y aspnetcore-runtime-7.0
  sudo apt-get install -y dotnet-runtime-7.0
}

install_golang_and_friends() {
  print_in_purple "\n • Installing golang \n\n"
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install golang-go gccgo-go golang-golang-x-tools -y
  sudo apt install hugo -y
  go install github.com/spf13/cobra-cli@latest
  sudo mkdir -p /var/cache/go
}

install_vim() {
  print_in_purple "\n • Installing vim \n\n"
  sudo apt update -y && sudo apt upgrade -y
  sudo apt install vim -y
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

install_docker() {
  print_in_purple "\n • Installing docker \n\n"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo "$UBUNTU_CODENAME") stable"
  sudo apt update -y
  sudo apt -y install docker-ce
  sudo usermod -aG docker $(whoami)
  newgrp docker
  docker --version
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

install_ghcli() {
  print_in_purple "\n • Installing github cli \n\n"
  type -p curl >/dev/null || sudo apt install curl -y
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
}

install_sqlite() {
  print_in_purple "\n • Installing VSCode \n\n"
  sudo apt update -y && \
  sudo apt install sqlite sqlitebrowser -y
}

install_mono() {
  print_in_purple "\n • Installing Mono \n\n"
  sudo apt update -y && \
  sudo apt install mono-complete -y
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {
  install_brewfile
  install_and_setup_postgres
  nvm_node_yarn
  install_typescript
  # install_az_cli
  install_dotnet
  install_powershell
  #install_docker
  install_VSCode
  install_vim
  install_golang_and_friends
  install_ghcli
  install_sqlite
  install_mon
}

main
