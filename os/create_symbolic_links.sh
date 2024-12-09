#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
  source "$DOT/utils/utils.sh"

create_symlinks() {
    declare -a FILES_TO_SYMLINK=(
        "shell/bash_aliases.d"
        "shell/bash_aliases"
        "shell/bash_autocompletion"
        "shell/bash_exports"
        "shell/bash_options"
        "shell/bash_colors"
        "shell/bash_profile"
        "shell/bash_prompt"
        "shell/bashrc"
        "shell/curlrc"
        "shell/inputrc"
        "git/gitconfig"
        "golang/cobra.yaml"
        "conf"
    )

    local sourceFile=""
    local targetFile=""

    for i in "${FILES_TO_SYMLINK[@]}"; do
        sourceFile="$(cd .. && pwd)/$i"
        targetFile="$HOME/.$(basename "$i")"

        if [ ! -e "$sourceFile" ]; then
            print_error "Source file '$sourceFile' does not exist."
            continue
        fi

        if [ ! -e "$targetFile" ]; then
            execute \
                "ln -fs $sourceFile $targetFile" \
                "$targetFile → $sourceFile"
        elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
            print_success "$targetFile → $sourceFile"
        else
            ask_for_confirmation "'$targetFile' already exists. Do you want to overwrite it?"
            if answer_is_yes; then
                mv "$targetFile" "${targetFile}.bak"
                print_in_green "Backed up $targetFile to ${targetFile}.bak"
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
    declare -a FILES_TO_SYMLINK=(
        ".config/autostart"
        ".config/terminator"
        ".config/plank"
        ".config/nvim"
        ".config/ranger"
        ".config/i3"
        ".config/neofetch"
        ".config/mutt"
        ".config/polybar"
        ".config/picom"
        ".config/omb"
        ".config/tmux"
    )

    local sourceFile=""
    local targetFile=""

    for i in "${FILES_TO_SYMLINK[@]}"; do
        sourceFile="$(cd .. && pwd)/$i"
        targetFile="$HOME/.config/$(basename "$i")"

        if [ ! -e "$sourceFile" ]; then
            print_error "Source file '$sourceFile' does not exist."
            continue
        fi

        if [ ! -e "$targetFile" ]; then
            execute \
                "ln -fs $sourceFile $targetFile" \
                "$targetFile → $sourceFile"
        elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
            print_success "$targetFile → $sourceFile"
        else
            ask_for_confirmation "'$targetFile' already exists. Do you want to overwrite it?"
            if answer_is_yes; then
                mv "$targetFile" "${targetFile}.bak"
                print_in_green "Backed up $targetFile to ${targetFile}.bak"
                execute \
                    "ln -fs $sourceFile $targetFile" \
                    "$targetFile → $sourceFile"
            else
                print_error "$targetFile → $sourceFile"
            fi
        fi
    done
}

main() {
    print_in_purple "\n • Creating symbolic links\n\n"
    create_symlinks "$@"

    print_in_purple "\n • Linking config directories\n\n"
    create_config_symlinks "$@"
}

main "$@"
