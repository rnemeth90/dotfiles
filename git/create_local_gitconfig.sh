#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

create_gitconfig_local() {

  declare -r FILE_PATH="$HOME/.gitconfig.local"

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if [ ! -e "$FILE_PATH" ] || [ -z "$FILE_PATH" ]; then

    printf "%s\n" \
   "[commit]
    # Sign commits using GPG.
    # https://help.github.com/articles/signing-commits-using-gpg/
    # gpgsign = true
    [init]
      defaultBranch = main
    [user]
      name = ryan nemeth
      email = ryannemeth@live.com
    # signingkey =" \
      >>"$FILE_PATH"
  fi

  print_result $? "$FILE_PATH"

}

clone_repos() {

  declare -a reposToClone=(
    "git@github.com:rnemeth90/lfcs-notes"
    "git@github.com:rnemeth90/ComicBookInventoryApp.git"
    "git@github.com:rnemeth90/rnemeth90.github.io.git"
    "git@github.com:rnemeth90/helm-charts.git"
    "git@github.com:rnemeth90/dockprom.git"
    "git@github.com:rnemeth90/notes.git"
    "git@github.com:rnemeth90/shell-scripts.git"
    "git@github.com:rnemeth90/core-dns-bouncer.git"
    "git@github.com:rnemeth90/PracticeProjects.git"
    "git@github.com:rnemeth90/docker-bind.git"
    "git@github.com:rnemeth90/docker-chronyd.git"
    "git@github.com:rnemeth90/DungeonMaster_v2.git"
    "git@github.com:rnemeth90/azure-code.git"
    "git@github.com:rnemeth90/pod-inspector.git"
  )

  local i=""
  local target=""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  if [ ! -e "/repos" ]; then
    echo "Creating /repos ..."
    sudo mkdir /repos && sudo chown $(whoami):$(whoami) /repos
  fi

  for i in "${reposToClone[@]}"; do
    target="/repos/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"
    # target="/repos/$(printf "%s" "$i" | sed "s:.*/::")"

    if [ ! -e "$target" ]; then
      print_in_purple "\n • cloning $i \n\n"
      cd /repos && git clone $i > /dev/null 2>&1
    else
      print_in_yellow "\n • $i already exists \n\n"
    fi
  done
}

setup_golang_workdir() {
  print_in_purple "\n • Configuring golang \n\n"
  if [ ! -e /repos/golang ]; then
    sudo mkdir -p /repos/golang && \
      # Change value after last '/' to your github username
      sudo mkdir -p /repos/golang/src/github.com/rnemeth90 && \
      sudo mkdir /repos/golang/pkg && \
      sudo mkdir /repos/golang/bin && \
      sudo chown -R $(whoami):$(whoami) /repos/golang/
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
    "git@github.com:rnemeth90/learngo.git"
    "git@github.com:rnemeth90/devopsforgo.git"
    "git@github.com:rnemeth90/go-practice.git"
    "git@github.com:rnemeth90/learngowithtests.git"
  )

  local i=""
  local targetFile=""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  for i in "${reposToClone[@]}"; do
    target="/repos/golang/src/github.com/rnemeth90/$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"
    # target="/repos/$(printf "%s" "$i" | sed "s:.*/::")"

    if [ ! -e "$target" ]; then
      print_in_purple "\n • cloning $i \n\n"
      cd /repos/golang/src/github.com/rnemeth90 && git clone $i > /dev/null 2>&1
    else
      print_in_yellow "\n • $i already exists \n\n"
    fi
  done
}

main() {
  print_in_purple "\n • Create local gitconfig file\n\n"
  create_gitconfig_local

  print_in_purple "\n • Cloning repos\n\n"
  clone_repos

  print_in_purple "\n • Setting up golang repos\n\n"
  setup_golang_workdir
  clone_golang_repos
}

main