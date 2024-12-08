#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    source "utils/utils.sh" &&

init_setup() {
    print_in_purple "\n • starting operating system setup \n\n"
    ./os/create_symbolic_links.sh
    print_in_green "\n • operating system setup done! \n\n"
    sleep 5
}

install_package_manager() {
  print_in_purple "\n • installing package managers \n\n"
  echo "...."
  print_in_purple "\n • finished installing package managers \n\n"
}

shell_setup() {
  print_in_purple "\n • create bash config \n\n"
  ./shell/create_local_shellconfig.sh
  sleep 5
  print_in_green "\n • bash config done! \n\n"
}

install_packages() {
  case "$OS" in
    mac)
        print_in_green "\n • Installing packages for Mac..."
        brew install $(cat ./os/packages/mac)
        sleep 5
        ;;
    debian)
        print_in_green "\n • Installing packages for Debian..."
        sudo apt update && sudo apt install -y $(cat ./os/packages/debian)
        ;;
    arch)
        print_in_green "\n • Installing packages for Arch..."
        sudo pacman -Syu --noconfirm
        sudo pacman -S --needed --noconfirm $(cat ./os/packages/arch)
        ;;
  esac

  print_in_green "\n • finished installing packages! \n\n"
  sleep 5
}

git_config() {
  print_in_purple "\n • create git config \n\n"
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
  print_in_purple "\n • installing fonts \n\n"
  ./os/fonts/fonts.sh
  print_in_green "\n finished installing fonts \n\n"
  sleep 5
}

main() {
  init_setup
  install_package_managers
  shell_setup
  install_packages
  git_config
  create_and_set_github_ssh_key
  install_fonts

  source ~/.bashrc
  print_in_green "\n • All done! Remember to set your fonts with lxappearance! \n"
}

# Allow calling single functions in script and run main if nothing is specified
"$@"

if [ "$1" == "" ]; then
  main
fi
