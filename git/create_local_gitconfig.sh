#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/utils/utils.sh"

create_gitconfig_local() {
  declare -r FILE_PATH="$HOME/.gitconfig.local"
  user=$(whoami)

  if [ ! -e "$FILE_PATH" ] || [ -z "$FILE_PATH" ]; then

    printf "%s\n" \
   "[commit]
    # Sign commits using GPG.
    # https://help.github.com/articles/signing-commits-using-gpg/
    # gpgsign = true
    [init]
      defaultBranch = main
    [user]
      name = $user
      email = ryannemeth@live.com
    # signingkey =" \
      >>"$FILE_PATH"
  fi

  print_result $? "$FILE_PATH"
}

clone_repos() {

  declare -a reposToClone=()

  while IFS= read -r repo; do
    if [ -n "$repo" ]; then
      reposToClone+=("git@github.com:${repo}.git")
    fi
  done < "$DOT/repos"

  local i=""
  local target=""

  if [ ! -e "$HOME/repos" ]; then
    echo "Creating $HOME/repos ..."
    sudo mkdir $HOME/repos && sudo chown -R $(whoami): $HOME/repos
  fi

  ensure_ssh_agent

  for i in "${reposToClone[@]}"; do
    target="$HOME/repos/$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

    if [ ! -e "$target" ]; then
      print_in_purple "\n • cloning $i \n\n"
      cd "$HOME/repos" && git clone "$i" > /dev/null 2>&1
    else
      print_in_yellow "\n • $i already exists \n\n"
    fi
  done
}

setup_golang_workdir() {
  print_in_purple "\n • Configuring golang \n\n"
  if [ ! -e "$HOME/go" ]; then
    mkdir -p "$HOME/go/bin" "$HOME/go/pkg" "$HOME/go/src"
  else
    print_in_yellow "\n • golang workspace already exists \n\n"
  fi
}

clone_golang_repos() {
  declare -a reposToClone=(
    "git@github.com:rnemeth90/go-test-web-server.git"
    "git@github.com:rnemeth90/go-password-generator.git"
    "git@github.com:rnemeth90/go-dad-jokes.git"
    "git@github.com:rnemeth90/golang.git"
    "git@github.com:rnemeth90/pwd.git"
    "git@github.com:rnemeth90/go-quiz-game.git"
    "git@github.com:rnemeth90/learngo.git"
    "git@github.com:rnemeth90/go-resolver.git"
    "git@github.com:rnemeth90/go-crash-dump-uploader.git"
    "git@github.com:rnemeth90/storage-blobs-go-quickstart.git"
    "git@github.com:rnemeth90/ancestorquotes.git"
    "git@github.com:rnemeth90/csv2json.git"
    "git@github.com:rnemeth90/url-pinger.git"
    "git@github.com:rnemeth90/github-cli-v2.git"
    "git@github.com:rnemeth90/crawley.git"
    "git@github.com:rnemeth90/hasher.git"
    "git@github.com:rnemeth90/httpstat.git"
    "git@github.com:rnemeth90/httping.git"
    "git@github.com:rnemeth90/httpbench.git"
    "git@github.com:rnemeth90/dnscache.git"
    "git@github.com:rnemeth90/learngo.git"
    "git@github.com:rnemeth90/devopsforgo.git"
    "git@github.com:rnemeth90/go-practice.git"
    "git@github.com:rnemeth90/learngowithtests.git"
  )

  local i=""
  local targetFile=""

  ensure_ssh_agent

  for i in "${reposToClone[@]}"; do
    target="$HOME/go/src/$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

    if [ ! -e "$target" ]; then
      print_in_purple "\n • cloning $i \n\n"
      cd "$HOME/go/src" && git clone "$i" > /dev/null 2>&1
    else
      print_in_yellow "\n • $i already exists \n\n"
    fi
  done
}

main() {
  print_in_purple "\n • Create local gitconfig file\n\n"
  create_gitconfig_local

  ask_for_confirmation "Do you want to clone Ryan's repositories?"
    if answer_is_yes; then
      print_in_purple "\n • Cloning repos\n\n"
      clone_repos

      print_in_purple "\n • Setting up golang repos\n\n"
      setup_golang_workdir
      clone_golang_repos
    fi
}

main
