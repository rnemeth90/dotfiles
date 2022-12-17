#!/bin/bash

general_settings_tweaks() {

  print_in_purple "\n • General Gnome tweaks... \n\n"

}

setup_golang() {
  print_in_purple "\n • General golang tweaks... \n\n"
  sudo mkdir -p /repos/golang
}

main() {
  setup_golang
}

main
