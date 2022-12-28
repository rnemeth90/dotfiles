#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_oh_my_bash() {
  print_in_purple "\n • Installing Oh My bash \n\n"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_fonts() {

  print_in_purple "\n • Install Fonts\n\n"
  sudo mkdir -p /home/ryan/.local/share/fonts/
  sudo unzip ../nerdfonts.zip -d ~/.local/share/fonts/
  fc-cache -fv
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
  print_in_purple "\n • Start setting up OS theme...\n\n"
  install_fonts
  #install_oh_my_bash
}

main
