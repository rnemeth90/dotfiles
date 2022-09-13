#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# DEV TOOLS

dev_tools_group() {

    print_in_purple "\n • Installing the Homebrew recommended dev tools with yum\n\n"

    sudo yum groupinstall 'Development Tools'

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# CRONIE

install_cronie() {

    print_in_purple "\n • Installing cronie for cronjobs\n\n"

    sudo dnf install -y cronie

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# BREWFILE

install_brewfile() {

    print_in_purple "\n • Installing Brewfile from brew/Brewfile\n\n"

    # Making sure that brew is found
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

    brew bundle --file ~/dotfiles/brew/Brewfile

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# KITTY TERMINAL EMULATOR

install_kitty() {

        print_in_purple "\n • Installing kitty terminal emulator \n\n"

        # download and setup some additional fonts for kitty & starship prompt (installed in previous step with brew)
        sudo mkdir /usr/share/fonts/nerd-fonts
        curl https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraMono.zip -o FiraMono.zip \
            && sudo unzip FiraMono.zip -d /usr/share/fonts/nerd-fonts

        sudo dnf install -y kitty

        mkdir ~/.config/kitty
        ln ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# POSTGRES

install_and_setup_postgres() {

    print_in_purple "\n • Installing and setting up postgres\n\n"

    # Install, init db, enable and start service
    sudo dnf install -y postgresql-server postgresql-contrib
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

    npm install -g typescript

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# AzCli

install_az_cli() {

    print_in_purple "\n • Installing Azure Cli \n\n"

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
    sudo dnf install azure-cli -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# dotnet

install_dotnet() {
    print_in_purple "\n • Installing dotnet \n\n"

    sudo dnf install dotnet-sdk-6.0 -y
    sudo dnf install aspnetcore-runtime-6.0 -y
    sudo dnf install dotnet-runtime-6.0 -y
}


# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

	dev_tools_group

    install_cronie

    install_brewfile

    install_kitty

    install_and_setup_postgres

    nvm_node_yarn

    install_typescript

    install_az_cli

    install_dotnet

}

main
