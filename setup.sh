#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR" &&
  source "utils/utils.sh"


init_setup() {
  print_in_green "\n • starting operating system setup \n\n"
  ./os/create_symbolic_links.sh
  print_in_green "\n • operating system setup done! \n\n"
  sleep 5
}

shell_setup() {
  print_in_green "\n • create bash config \n\n"
  ./os/create_local_shellconfig.sh
  print_in_green "\n • bash done! \n\n"
  sleep 5
}

install_package_managers() {
  print_in_green "\n • installing package managers \n\n"
  ./os/extensions_and_pkg_managers.sh
  print_in_green "\n • finished installing package managers \n\n"
  sleep 5
}

install_packages_arch() {
    local packages=("$@")

    for pkg in "${packages[@]}"; do
        echo "Installing package: $pkg"

        if sudo pacman -S --noconfirm --needed "$pkg"; then
            echo "✅ Successfully installed $pkg with pacman."
        else
            echo "⚠️ Failed to install $pkg with pacman. Trying yay..."
            if yay -S --noconfirm --needed "$pkg"; then
                echo "✅ Successfully installed $pkg with yay."
            else
                echo "❌ Failed to install $pkg with both pacman and yay."
            fi
        fi
    done
}

install_packages() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
  elif [[ -f /etc/debian_version ]]; then
    OS="debian"
  elif [[ -f /etc/arch-release ]]; then
    OS="arch"
  fi

  case "$OS" in
  mac)
    print_in_green "\n • Installing packages for Mac..."
    brew install $(cat "$DOTFILES_DIR/os/mac/packages")
    sleep 5
    ;;
  debian)
    print_in_green "\n • Installing packages for Debian..."
    sudo apt update && sudo apt install -y $(cat "$DOTFILES_DIR/os/debian/packages")
    ;;
  arch)
    print_in_green "\n • Installing packages for Arch (Pacman)..."
    install_packages_arch $(cat "$DOTFILES_DIR/os/arch/packages")
    ;;
  esac

  print_in_green "\n • finished installing packages! \n\n"
  sleep 5
}

git_config() {
  print_in_green "\n • create git config \n\n"
  ./git/create_local_gitconfig.sh
  print_in_green "\n • bash git done! \n\n"
  sleep 5
}

create_and_set_github_ssh_key() {
  ./git/set_github_ssh_key.sh
  print_in_green "\n • Github ssh key creation done! \n\n"
  sleep 5
}

install_fonts() {
  print_in_green "\n • installing fonts \n\n"
  ./os/common/fonts/fonts.sh
  print_in_green "\n finished installing fonts \n\n"
  sleep 5
}

everything_else() {
  print_in_green "\n • installing everything else \n\n"
  ./os/common/go.sh
  ./os/common/cargo.sh
  if [[ -f /etc/debian_version ]]; then
    ./os/common/manual.sh
  fi
  ./os/common/npm.sh
  ./os/common/pip.sh
  print_in_green "\n finished installing everything else \n\n"
  sleep 5

}

main() {
  init_setup
  install_package_managers
  shell_setup
  install_packages
  git_config
  # create_and_set_github_ssh_key
  install_fonts
  everything_else

  source ~/.bashrc
  print_in_green "\n • All done! Remember to set your fonts with lxappearance! \n"
}

# Allow calling single functions in script and run main if nothing is specified
"$@"

if [ "$1" == "" ]; then
  main
fi
