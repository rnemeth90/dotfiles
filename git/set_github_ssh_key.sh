#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/utils/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

add_ssh_configs() {

  printf "%s\n" \
    "Host github.com" \
    "  IdentityFile $1" \
    "  LogLevel ERROR" >>~/.ssh/config

  print_result $? "Add SSH configs"

}

copy_public_ssh_key_to_clipboard() {
  if cmd_exists "xclip"; then
    xclip -selection clip <"$1"
    print_result $? "Copy public SSH key to clipboard"
  else
    print_warning "Please copy the public SSH key ($1) to clipboard"
  fi
}

generate_ssh_keys() {
  ask "Please provide an email address: " && printf "\n"
  ssh-keygen -t ed25519 -C "$(get_answer)" -f "$1"
  print_result $? "Generate SSH keys"
}

open_github_ssh_page() {
  declare -r GITHUB_SSH_URL="https://github.com/settings/ssh"
  if cmd_exists "xdg-open"; then
    xdg-open "$GITHUB_SSH_URL"
  else
    print_warning "Please add the public SSH key to GitHub ($GITHUB_SSH_URL)"
  fi
}

set_github_ssh_key() {
  local sshKeyFileName="$HOME/.ssh/github"
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # If there is already a file with that
  # name, generate another, unique, file name.
  if [ -f "$sshKeyFileName" ]; then
    sshKeyFileName="$(mktemp -u "$HOME/.ssh/github_XXXXX")"
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  generate_ssh_keys "$sshKeyFileName"
  add_ssh_configs "$sshKeyFileName"
  copy_public_ssh_key_to_clipboard "${sshKeyFileName}.pub"
  open_github_ssh_page
  test_ssh_connection &&
    rm "${sshKeyFileName}.pub"
}

test_ssh_connection() {
  local max_attempts=12
  local attempt=0

  chmod 600 ~/.ssh/config
  chown "$USER" ~/.ssh/config

  while [ $attempt -lt $max_attempts ]; do
    attempt=$((attempt + 1))
    ssh -T git@github.com
    if [ $? -eq 1 ]; then
      print_success "SSH connection to GitHub verified."
      return 0
    fi
    print_warning "Attempt $attempt/$max_attempts — retrying in 5s..."
    sleep 5
  done

  print_error "Failed to verify SSH connection after $max_attempts attempts."
  return 1
}

main() {
  print_in_purple "\n • Set up GitHub SSH keys\n\n"
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ssh -T git@github.com &>/dev/null
  if [ $? -ne 1 ]; then
    set_github_ssh_key
  fi
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  print_result $? "Set up GitHub SSH keys"
}

main
