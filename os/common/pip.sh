#!/bin/bash

# Install pip packages

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    source "$DOT/utils/utils.sh"

check_pip() {
    if ! command -v pip &>/dev/null; then
        print_in_red "\n [✖] pip is not installed. Please install pip first. \n"
        exit 1
    fi
}

install_pip_packages() {
    local packages=("$@") # Accept a list of packages as arguments

    for package in "${packages[@]}"; do
        print_in_purple "\n • Installing $package \n\n"

        if pip show "$package" &>/dev/null; then
            print_in_green "\n [✔] $package is already installed. Skipping...\n"
        else
            if pip install "$package"; then
                print_in_green "\n [✔] Successfully installed $package! \n"
            else
                print_in_red "\n [✖] Failed to install $package. \n"
                exit 1
            fi
        fi
    done
}

main() {
  check_pip

  # List of packages to install
  packages=(
      black
      flake8
      requests
      mypy
      numpy
      thefuck
  )

  install_pip_packages "${packages[@]}"
}
