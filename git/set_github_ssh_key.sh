#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/utils/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ensure_gh_installed is defined in utils/utils.sh (shared with setup.sh).

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

# Uploads the public key to GitHub via the API using an authenticated `gh`.
# Returns 0 on success, 1 if `gh` is missing/unauthenticated so callers can
# fall back to the manual clipboard/browser flow.
upload_public_ssh_key_via_gh() {
  local pubKeyFile="$1"

  if ! cmd_exists "gh"; then
    return 1
  fi

  if ! gh auth status &>/dev/null; then
    print_warning "gh CLI is installed but not authenticated (run 'gh auth login' to enable automatic key upload)"
    return 1
  fi

  local title="$(hostname)-$(date +%Y%m%d%H%M%S)"
  if gh ssh-key add "$pubKeyFile" --title "$title" &>>"$LOG_FILE"; then
    print_success "Uploaded public SSH key to GitHub via gh CLI (title: $title)"
    return 0
  else
    print_warning "gh ssh-key add failed — falling back to manual upload"
    return 1
  fi
}

generate_ssh_keys() {
  local email="${GITHUB_SSH_EMAIL:-}"
  if [ -z "$email" ]; then
    ask "Please provide an email address: " && printf "\n"
    email="$(get_answer)"
  fi
  ssh-keygen -t ed25519 -C "$email" -f "$1"
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

  ensure_gh_installed
  if upload_public_ssh_key_via_gh "${sshKeyFileName}.pub"; then
    rm "${sshKeyFileName}.pub"
  else
    copy_public_ssh_key_to_clipboard "${sshKeyFileName}.pub"
    open_github_ssh_page
    test_ssh_connection &&
      rm "${sshKeyFileName}.pub"
  fi
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
