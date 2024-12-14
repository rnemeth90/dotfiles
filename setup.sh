#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  source "utils/utils.sh"


init_setup() {
  print_in_green "\n • starting operating system setup \n\n"
  ./os/create_symbolic_links.sh
  print_in_green "\n • operating system setup done! \n\n"
  sleep 5
}

shell_setup() {
  print_in_green "\n • create bash config \n\n"
  ./os/create_local_shel.sh
  print_in_green "\n • bash done! \n\n"
  sleep 5
}

install_package_managers() {
  print_in_green "\n • installing package managers \n\n"
  ./os/extensions_and_pkg_managers.sh
  print_in_green "\n • finished installing package managers \n\n"
  sleep 5
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
    brew install $(cat ./os/mac/packages)
    sleep 5
    ;;
  debian)
    print_in_green "\n • Installing packages for Debian..."
    sudo apt update && sudo apt install -y $(cat ./os/debian/packages)
    ;;
  arch)
    print_in_green "\n • Installing packages for Arch (Pacman)..."
    if ! sudo pacman -Syu --noconfirm && sudo pacman -S --needed --noconfirm $(cat ./os/arch/packages); then
      print_in_yellow "\n • Pacman installation failed. Falling back to yay..."
      if ! command -v yay &>/dev/null; then
        print_in_green "\n • Installing yay..."
        git clone https://aur.archlinux.org/yay.git /usr/bin/local/yay
        cd /usr/bin/local/yay || exit 1
        makepkg -si --noconfirm
        cd - || exit 1
      fi
      yay -Syu --noconfirm && yay -S --needed --noconfirm $(cat ./os/arch/packages)
    fi
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
  ./os/fonts/fonts.sh
  print_in_green "\n finished installing fonts \n\n"
  sleep 5
}

everything_else() {
  print_in_green "\n • installing everything else \n\n"
  ./os/common/go.sh
  ./os/common/cargo.sh
  ./os/common/manual.sh
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
