# This can be improved but I am lazy

#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

create_symlinks() {

  declare -a FILES_TO_SYMLINK=(

    "shell/bash_aliases"
    "shell/bash_autocompletion"
    "shell/bash_exports"
    "shell/bash_options"
    "shell/bash_profile"
    "shell/bash_prompt"
    "shell/bashrc"
    "shell/curlrc"
    "shell/inputrc"

    "git/gitconfig"
    "git/gitignore"
  )

  local i=""
  local sourceFile=""
  local targetFile=""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  for i in "${FILES_TO_SYMLINK[@]}"; do

    sourceFile="$(cd .. && pwd)/$i"
    targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

    if [ ! -e "$targetFile" ]; then

      execute \
        "ln -fs $sourceFile $targetFile" \
        "$targetFile → $sourceFile"

    elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
      print_success "$targetFile → $sourceFile"
    else

      ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
      if answer_is_yes; then

        rm -rf "$targetFile"

        execute \
          "ln -fs $sourceFile $targetFile" \
          "$targetFile → $sourceFile"

      else
        print_error "$targetFile → $sourceFile"
      fi

    fi

  done

}

create_config_symlinks() {

  # DO NOT INCLUDE THE LAST '/' IN THE PATHS BELOW!!
  declare -a FILES_TO_SYMLINK=(
    ".config/autostart"
    ".config/terminator"
  )

  local i=""
  local sourceFile=""
  local targetFile=""

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  for i in "${FILES_TO_SYMLINK[@]}"; do

    sourceFile="$(cd .. && pwd)/$i"
    targetFile="$HOME/.config/$(printf "%s" "$i" | sed 's:.*/::')"

    if [ ! -e "$targetFile" ]; then

      execute \
        "ln -fs $sourceFile $targetFile" \
        "$targetFile → $sourceFile"

    elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
      print_success "$targetFile → $sourceFile"
    else

      ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
      if answer_is_yes; then

        rm -rf "$targetFile"

        execute \
          "ln -fs $sourceFile $targetFile" \
          "$targetFile → $sourceFile"

      else
        print_error "$targetFile → $sourceFile"
      fi

    fi

  done

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
  # print_in_purple "\n • Create symbolic links\n\n"
  # create_symlinks "$@"

  print_in_purple "\n • Linking config dirs\n\n"
  create_config_symlinks "$@"
  # ln -s ~/dotfiles/.config/autostart/ ~/.config/autostart
  # ln -s ~/dotfiles/.config/terminator/ ~/.config/terminator
}

main "$@"
