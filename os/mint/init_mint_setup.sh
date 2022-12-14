#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

set_hostname() {
  print_in_purple "\n • Setting hostname... \n\n"
  print_in_yellow "\nType in your hostname:\n"
  read HOSTNAME
  hostnamectl set-hostname $HOSTNAME
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

upgrade_apt() {
  print_in_purple "\n • Upgrading... \n\n"
  sudo apt upgrade -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

update_device_firmware() {
  print_in_purple "\n • Updating device firmwares... \n\n"
  sudo fwupdmgr get-devices
  sudo fwupdmgr refresh --force
  sudo fwupdmgr get-updates
  sudo fwupdmgr update
  print_in_yellow "\n !!! Don't restart yet if doing full setup! \n\n"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_xclip() {
  print_in_purple "\n • Installing xclip for setup process... \n\n"
  sudo apt install -y xclip
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

  set_hostname

  upgrade_apt

  #update_device_firmware

  install_xclip

}

main
