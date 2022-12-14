#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_brewfile() {

    print_in_purple "\n • Installing Brewfile from brew/Brewfile\n\n"

    # Making sure that brew is found
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

    brew bundle --file ~/dotfiles/brew/Brewfile

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# POSTGRES

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

# NVM, NODE AND YARN

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

# TYPESCRIPT

install_typescript() {

    print_in_purple "\n • Installing typescript globally\n\n"

    sudo apt install -y node-typescript
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_az_cli() {

    print_in_purple "\n • Installing Azure Cli \n\n"

    sudo apt-get update
    sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
    curl -sL https://packages.microsoft.com/keys/microsoft.asc |
      gpg --dearmor |
      sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list
    sudo apt-get update
    sudo apt-get install azure-cli
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_dotnet() {
  print_in_purple "\n • Installing dotnet \n\n"

  wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
  sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-7.0
  sudo apt-get update && \
    sudo apt-get install -y aspnetcore-runtime-7.0
}


# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

    install_brewfile

    install_and_setup_postgres

    nvm_node_yarn

    install_typescript

    install_az_cli

    install_dotnet

}

main
