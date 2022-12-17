#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

add_flatpak_store_and_update() {
  print_in_purple "\n • Add flatpak store and update\n\n"
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak update
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_snap() {
  print_in_purple "\n • Installing snap\n\n"
  sudo apt install -y snapd
  sudo ln -s /var/lib/snapd/snap /snap
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_homebrew() {
  print_in_purple "\n • Installing Homebrew \n\n"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {
  add_flatpak_store_and_update
  install_snap
  install_homebrew
}

main
