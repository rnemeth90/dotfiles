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
        "conf/.Xresources"
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

create_bin_symlink() {
    local sourceDir="$(cd .. && pwd)/bin"
    local targetDir="$HOME/bin"

    if [ ! -e "$sourceDir" ]; then
        print_error "Source directory '$sourceDir' does not exist."
        return
    fi

    if [ ! -e "$targetDir" ]; then
        execute \
            "ln -fs $sourceDir $targetDir" \
            "$targetDir → $sourceDir"
    elif [ "$(readlink "$targetDir")" == "$sourceDir" ]; then
        print_success "$targetDir → $sourceDir"
    else
        ask_for_confirmation "'$targetDir' already exists. Do you want to overwrite it?"
        if answer_is_yes; then
            mv "$targetDir" "${targetDir}.bak"
            print_in_green "Backed up $targetDir to ${targetDir}.bak"
            execute \
                "ln -fs $sourceDir $targetDir" \
                "$targetDir → $sourceDir"
        else
            print_error "$targetDir → $sourceDir"
        fi
    fi
}

create_config_symlinks() {
    declare -a FILES_TO_SYMLINK=(
        "config/alacritty"
        "config/aria2"
        "config/atuin"
        "config/autostart"
        "config/bat"
        "config/terminator"
        "config/plank"
        "config/nvim"
        "config/nvim-lazy"
        "config/ranger"
        "config/i3"
        "config/neofetch"
        "config/mutt"
        "config/polybar"
        "config/rofi"
        "config/dunst"
        "config/picom"
        "config/tmux"
        "config/powershell"
        "config/dir_colors"
    )

    local sourceFile=""
    local targetFile=""

    # check if .config directory exists, if not create it
    if [ ! -d "$HOME/.config" ]; then
      mkdir -p "$HOME/.config"
      print_in_green "Created $HOME/.config directory"
    fi

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

    print_in_purple "\n • Linking bin directory\n\n"
    create_bin_symlink "$@"

    print_in_purple "\n • Linking config directories\n\n"
    create_config_symlinks "$@"
}

main "$@"
