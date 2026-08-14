#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR" && source "utils/utils.sh"

_TOTAL_STEPS=8

# ─────────────────────────────────────────────

init_setup() {
  print_step 1 $_TOTAL_STEPS "Creating symbolic links"
  ./os/create_symbolic_links.sh
}

shell_setup() {
  print_step 2 $_TOTAL_STEPS "Configuring shell"
  ./os/create_local_shellconfig.sh
  print_success "Shell config done"
}

install_package_managers() {
  print_step 3 $_TOTAL_STEPS "Installing package managers"
  ./os/extensions_and_pkg_managers.sh
  print_success "Package managers ready"
}

install_packages_arch() {
  local packages=("$@")
  local total=${#packages[@]}
  local i=0

  for pkg in "${packages[@]}"; do
    ((i++))
    printf "  %s  [%d/%d] %s\r" "$(_cyan "·")" "$i" "$total" "$pkg"
    if sudo pacman -S --noconfirm --needed "$pkg" >>"$LOG_FILE" 2>&1; then
      print_debug "pacman: $pkg"
    elif yay -S --noconfirm --needed "$pkg" >>"$LOG_FILE" 2>&1; then
      print_debug "yay: $pkg"
    else
      print_warning "Failed to install $pkg (pacman + yay)"
    fi
  done
  printf "%*s\r" 60 ""   # clear progress line
  print_success "Packages installed ($total packages)"
}

install_packages() {
  print_step 4 $_TOTAL_STEPS "Installing packages"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
  elif [[ -f /etc/debian_version ]]; then
    OS="debian"
  elif [[ -f /etc/arch-release ]]; then
    OS="arch"
  fi

  case "$OS" in
    mac)
      print_info "Installing Homebrew packages..."
      brew install $(cat "$DOTFILES_DIR/os/mac/packages") >>"$LOG_FILE" 2>&1
      print_success "Homebrew packages installed"
      ;;
    debian)
      print_info "Installing apt packages..."
      sudo apt update >>"$LOG_FILE" 2>&1
      sudo apt install -y $(cat "$DOTFILES_DIR/os/debian/packages") >>"$LOG_FILE" 2>&1
      print_success "Apt packages installed"
      ;;
    arch)
      print_info "Installing Arch packages..."
      install_packages_arch $(cat "$DOTFILES_DIR/os/arch/packages")
      ;;
    *)
      print_warning "Unknown OS — skipping package installation"
      ;;
  esac
}

setup_tlp() {
  [[ -f /etc/arch-release ]] || return 0

  print_section "TLP Battery Management"

  print_info "Installing tp_smapi-dkms from AUR..."
  if yay -S --noconfirm --needed tp_smapi-dkms >>"$LOG_FILE" 2>&1; then
    print_success "tp_smapi-dkms installed (T420 battery thresholds enabled)"
  else
    print_warning "tp_smapi-dkms unavailable — battery thresholds will not apply"
  fi

  execute "sudo cp '$DOTFILES_DIR/os/arch/tlp.conf' /etc/tlp.conf" \
    "Installing TLP config"
  execute "sudo systemctl enable --now tlp" \
    "Enabling TLP service"
  execute "sudo systemctl enable tlp-sleep" \
    "Enabling TLP sleep hook"
}

setup_arch_system() {
  [[ -f /etc/arch-release ]] || return 0

  print_section "Arch System Configuration"

  execute "sudo cp '$DOTFILES_DIR/os/arch/etc/systemd/logind.conf' /etc/systemd/logind.conf" \
    "Installing logind.conf (lid-close suspend)"

  execute "sudo mkdir -p /etc/xdg/reflector && sudo cp '$DOTFILES_DIR/os/arch/etc/xdg/reflector/reflector.conf' /etc/xdg/reflector/reflector.conf" \
    "Installing reflector mirror config"

  execute "sudo mkdir -p /etc/pacman.d/hooks && sudo cp '$DOTFILES_DIR/os/arch/etc/pacman.d/hooks/'*.hook /etc/pacman.d/hooks/" \
    "Installing pacman hooks"

  print_section "Enabling Services"

  execute "sudo systemctl enable --now NetworkManager" "NetworkManager"
  execute "sudo systemctl enable --now bluetooth"      "Bluetooth"
  execute "sudo systemctl enable --now reflector.timer" "Reflector (weekly mirror update)"
  execute "systemctl --user enable --now pipewire"      "Pipewire"
  execute "systemctl --user enable --now pipewire-pulse" "Pipewire-pulse"
}

git_config() {
  print_step 5 $_TOTAL_STEPS "Configuring git"
  ./git/create_local_gitconfig.sh
  print_success "Git config done"
}

install_fonts() {
  print_step 6 $_TOTAL_STEPS "Installing fonts"
  ./os/common/fonts/fonts.sh >>"$LOG_FILE" 2>&1
  print_success "Fonts installed"
}

everything_else() {
  print_step 7 $_TOTAL_STEPS "Installing language toolchains"

  execute "./os/common/go.sh"    "Go tools"
  execute "./os/common/cargo.sh" "Rust/Cargo tools"
  execute "./os/common/npm.sh"   "npm global packages"
  execute "./os/common/pip.sh"   "pip packages"

  if [[ -f /etc/debian_version ]]; then
    execute "./os/common/manual.sh" "Manual installs (Debian)"
  fi
}

main() {
  print_section "Dotfiles Setup"
  print_info "Log file: $LOG_FILE"

  sudo_keepalive

  init_setup
  install_package_managers
  shell_setup
  install_packages
  setup_tlp
  setup_arch_system
  git_config
  install_fonts
  everything_else

  print_step 8 $_TOTAL_STEPS "Finalising"
  # shellcheck disable=SC1090
  source ~/.bashrc

  print_section "Setup Complete"
  print_success "Dotfiles installed successfully"
  print_warning "Remember to set your fonts with lxappearance"
  print_log_path
  print_duration
}

# Allow calling individual functions: ./setup.sh setup_tlp
"$@"

if [[ "$#" -eq 0 ]]; then
  main
fi
