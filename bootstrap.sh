#!/bin/bash
#
# Bootstrap script for a completely fresh machine that doesn't yet have
# these dotfiles (or even git/gh) installed.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rnemeth90/dotfiles/main/bootstrap.sh | bash
#
# This script has no dependency on anything else in the repo (it can't --
# the repo isn't cloned yet), so it intentionally duplicates a minimal
# amount of OS-detection/package-install logic from utils/utils.sh.
#
# It will:
#   1. Detect the OS (macOS, Debian/Ubuntu, or Arch)
#   2. Install git and gh (GitHub CLI) if they're missing
#   3. Clone the dotfiles repo (if not already present) into ~/dotfiles
#   4. chmod +x every .sh file in the repo
#   5. Hand off to ./setup.sh, which takes over from there

set -euo pipefail

REPO_URL="https://github.com/rnemeth90/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

_bold() { printf "\033[1m%s\033[0m" "$1"; }
_cyan() { printf "\033[36m%s\033[0m" "$1"; }
_red() { printf "\033[31m%s\033[0m" "$1"; }

info() { printf "  %s %s\n" "$(_cyan "→")" "$1"; }
success() { printf "  %s %s\n" "$(_cyan "✓")" "$1"; }
error() { printf "  %s %s\n" "$(_red "✗")" "$1" >&2; }

cmd_exists() { command -v "$1" &>/dev/null; }

detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "mac"
  elif [[ -f /etc/arch-release ]]; then
    echo "arch"
  elif [[ -f /etc/debian_version ]]; then
    echo "debian"
  else
    echo "unknown"
  fi
}

install_prereqs() {
  local os
  os="$(detect_os)"

  local need_git=0 need_gh=0
  cmd_exists git || need_git=1
  cmd_exists gh || need_gh=1

  if [[ "$need_git" -eq 0 && "$need_gh" -eq 0 ]]; then
    success "git and gh already installed"
    return 0
  fi

  info "Installing prerequisites for $os (git: $([[ $need_git -eq 1 ]] && echo missing || echo ok), gh: $([[ $need_gh -eq 1 ]] && echo missing || echo ok))"

  case "$os" in
    mac)
      if ! cmd_exists brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
      fi
      [[ "$need_git" -eq 1 ]] && brew install git
      [[ "$need_gh" -eq 1 ]] && brew install gh
      ;;
    debian)
      sudo apt update
      [[ "$need_git" -eq 1 ]] && sudo apt install -y git
      if [[ "$need_gh" -eq 1 ]]; then
        if ! cmd_exists gh; then
          # Official GitHub CLI apt repo (see cli.github.com)
          sudo mkdir -p -m 755 /etc/apt/keyrings
          curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
          sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
          echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
            sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
          sudo apt update
          sudo apt install -y gh
        fi
      fi
      ;;
    arch)
      [[ "$need_git" -eq 1 ]] && sudo pacman -S --noconfirm --needed git
      [[ "$need_gh" -eq 1 ]] && sudo pacman -S --noconfirm --needed gh
      ;;
    *)
      error "Unknown OS — please install git and gh manually, then re-run this script."
      exit 1
      ;;
  esac

  cmd_exists git || { error "git installation failed"; exit 1; }
  cmd_exists gh || { error "gh installation failed"; exit 1; }
  success "git and gh installed"
}

clone_dotfiles() {
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    success "Dotfiles already cloned at $DOTFILES_DIR"
  else
    info "Cloning dotfiles into $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    success "Dotfiles cloned"
  fi
}

main() {
  printf "\n%s\n\n" "$(_bold "Bootstrapping dotfiles...")"

  install_prereqs
  clone_dotfiles

  cd "$DOTFILES_DIR"
  find . -type f -iname "*.sh" -exec chmod +x {} \;

  info "Handing off to setup.sh..."
  exec ./setup.sh
}

main "$@"
