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
    "git@github.com:rnemeth90/monkey.git"
    "git@github.com:rnemeth90/raggy.git"
    "git@github.com:rnemeth90/rnemeth90.github.io.git"
    "git@github.com:rnemeth90/notes.git"
    "git@github.com:rnemeth90/dotfiles.git"
    "git@github.com:rnemeth90/yahba.git"
    "git@github.com:rnemeth90/gomics.git"
    "git@github.com:rnemeth90/homelab.git"
    "git@github.com:rnemeth90/helm-charts.git"
    "git@github.com:rnemeth90/certdump.git"
    "git@github.com:rnemeth90/terraform-provider-azurerm.git"
    "git@github.com:rnemeth90/kubernetes-ingress.git"
    "git@github.com:rnemeth90/nvim-show-keymaps.git"
    "git@github.com:rnemeth90/ostep-homework.git"
    "git@github.com:rnemeth90/gator.git"
    "git@github.com:rnemeth90/Flipper.git"
    "git@github.com:rnemeth90/Pokedex.git"
    "git@github.com:rnemeth90/wordlists.git"
    "git@github.com:rnemeth90/boot-dev-static-site-gen.git"
    "git@github.com:rnemeth90/toy-ai-agent.git"
    "git@github.com:rnemeth90/asteroids.git"
    "git@github.com:rnemeth90/bookbot.git"
    "git@github.com:rnemeth90/webflyx.git"
    "git@github.com:rnemeth90/linux.git"
    "git@github.com:rnemeth90/go-password-generator.git"
    "git@github.com:rnemeth90/sidekick.git"
    "git@github.com:rnemeth90/codecrafters-shell-go.git"
    "git@github.com:rnemeth90/asm.git"
    "git@github.com:rnemeth90/linux-insides.git"
    "git@github.com:rnemeth90/pihole-kubernetes.git"
    "git@github.com:rnemeth90/httping.git"
    "git@github.com:rnemeth90/Linux-Kernel-Programming_2E.git"
    "git@github.com:rnemeth90/bible.git"
    "git@github.com:rnemeth90/health-probe-watcher.git"
    "git@github.com:rnemeth90/training.git"
    "git@github.com:rnemeth90/ansible-playbooks.git"
    "git@github.com:rnemeth90/kubernetes.git"
    "git@github.com:rnemeth90/container-library.git"
    "git@github.com:rnemeth90/kube-linter.git"
    "git@github.com:rnemeth90/hugo-theme-anubis.git"
    "git@github.com:rnemeth90/hugo-coder.git"
    "git@github.com:rnemeth90/AI-Assisted-Development.git"
    "git@github.com:rnemeth90/Much-Assembly-Required.git"
    "git@github.com:rnemeth90/ckad-exercises.git"
    "git@github.com:rnemeth90/example-voting-app.git"
    "git@github.com:rnemeth90/ant.git"
    "git@github.com:rnemeth90/mutt-wizard.git"
    "git@github.com:rnemeth90/httpbench.git"
    "git@github.com:rnemeth90/greenlight.git"
    "git@github.com:rnemeth90/Designing-and-Implementing-Microsoft-Azure-Networking-Solutions.git"
    "git@github.com:rnemeth90/samba.git"
    "git@github.com:rnemeth90/getheaders.git"
    "git@github.com:rnemeth90/httpedia.git"
    "git@github.com:rnemeth90/linkedin2username.git"
    "git@github.com:rnemeth90/ostep-projects.git"
    "git@github.com:rnemeth90/rnemeth90.git"
    "git@github.com:rnemeth90/snippetbox.git"
    "git@github.com:rnemeth90/crayola.git"
    "git@github.com:rnemeth90/perf-tools.git"
    "git@github.com:rnemeth90/ostep-code.git"
    "git@github.com:rnemeth90/rotcipher.git"
    "git@github.com:rnemeth90/goal.git"
    "git@github.com:rnemeth90/dnscache.git"
    "git@github.com:rnemeth90/podcrashcollector.git"
    "git@github.com:rnemeth90/chattygo.git"
    "git@github.com:rnemeth90/manifesto.git"
    "git@github.com:rnemeth90/PowerShell.git"
    "git@github.com:rnemeth90/csharp.git"
    "git@github.com:rnemeth90/dnsfixer.git"
    "git@github.com:rnemeth90/taint-remover.git"
    "git@github.com:rnemeth90/Building-Modern-CLI-Applications-in-Go.git"
    "git@github.com:rnemeth90/markdown-notes.git"
    "git@github.com:rnemeth90/go-test-web-server.git"
    "git@github.com:rnemeth90/mdp.git"
    "git@github.com:rnemeth90/csv2json.git"
    "git@github.com:rnemeth90/hashy.git"
    "git@github.com:rnemeth90/todo.git"
    "git@github.com:rnemeth90/colstats.git"
    "git@github.com:rnemeth90/walk.git"
    "git@github.com:rnemeth90/wc.git"
    "git@github.com:rnemeth90/azure-vm-with-load-balancer.git"
    "git@github.com:rnemeth90/terraform-aks-with-nat-gateway.git"
    "git@github.com:rnemeth90/github-cli-v2.git"
    "git@github.com:rnemeth90/httpstat.git"
    "git@github.com:rnemeth90/cs11dotnet7.git"
    "git@github.com:rnemeth90/gophercises.git"
    "git@github.com:rnemeth90/golang-github-action-example.git"
    "git@github.com:rnemeth90/learngowithtests.git"
    "git@github.com:rnemeth90/computer_science.git"
    "git@github.com:rnemeth90/devopsforgo.git"
    "git@github.com:rnemeth90/Go-for-DevOps.git"
    "git@github.com:rnemeth90/lfcs-notes.git"
    "git@github.com:rnemeth90/dockprom.git"
    "git@github.com:rnemeth90/golang.git"
    "git@github.com:rnemeth90/testing.git"
    "git@github.com:rnemeth90/crawley.git"
    "git@github.com:rnemeth90/core-dns-bouncer.git"
    "git@github.com:rnemeth90/PracticeProjects.git"
    "git@github.com:rnemeth90/docker-bind.git"
    "git@github.com:rnemeth90/docker-chronyd.git"
    "git@github.com:rnemeth90/DungeonMaster_v2.git"
    "git@github.com:rnemeth90/azure-code.git"
    "git@github.com:rnemeth90/MusicStoreApi.git"
    "git@github.com:rnemeth90/FountainOfObjects.git"
    "git@github.com:rnemeth90/ComicBookInventoryApp.git"
    "git@github.com:rnemeth90/go-resources.git"
    "git@github.com:rnemeth90/storage-blobs-go-quickstart.git"
    "git@github.com:rnemeth90/kube-prometheus.git"
    "git@github.com:rnemeth90/terraform-quickstart-templates.git"
    "git@github.com:rnemeth90/Northwind.git"
    "git@github.com:rnemeth90/eShopOnContainers.git"
    "git@github.com:rnemeth90/DotnetSolid.git"
    "git@github.com:rnemeth90/AzureResourceInventory.git"
    "git@github.com:rnemeth90/LinkCrawler.git"
    "git@github.com:rnemeth90/edabit.git"
    "git@github.com:rnemeth90/BoutiqueStoreApp.git"
    "git@github.com:rnemeth90/google-dorks-cheatsheet.git"
    "git@github.com:rnemeth90/PowerShellPracticeAndStyle.git"
    "git@github.com:rnemeth90/pure-sh-bible.git"
    "git@github.com:rnemeth90/redis-app.git"
    "git@github.com:rnemeth90/net-utils.git"
    "git@github.com:rnemeth90/kubernetes-sftp.git"
    "git@github.com:rnemeth90/pod-inspector.git"
    "git@github.com:rnemeth90/gitignore.git"
    "git@github.com:rnemeth90/netshoot.git"
    "git@github.com:rnemeth90/azure-tenant-maintenance.git"
    "git@github.com:rnemeth90/CSharp-9-CheatSheet.git"
    "git@github.com:rnemeth90/podtail.git"
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
