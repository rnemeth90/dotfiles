#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/utils/utils.sh"

check_cargo() {
    if ! command -v cargo &>/dev/null; then
        print_in_red "\n [✖] cargo is not installed. Please install Rust and cargo first. \n"
        exit 1
    fi
}

install_cargo_package() {
    local package=$1

    print_in_green "\n • Installing $package... \n\n"

    if cargo install --list | grep -q "$package"; then
        print_in_yellow "\n [✔] $package is already installed. Skipping...\n"
    else
        if cargo install "$package"; then
            print_in_green "\n [✔] Successfully installed $package!\n"
        else
            print_in_red "\n [✖] Failed to install $package.\n"
            exit 1
        fi
    fi
}

main() {
    check_cargo

    packages=(
        vivid
        stylua
        tree-sitter-cli
        bottom # 17m, `btm`, Yet another cross-platform graphical process/system monitor (rust) - interactive with mouse and shortcuts
        diskus # 3m, minimal, 3-10x faster alternative to `du -sh`
        eza # 6m, maintained fork of exa; `eza --long --header --icons --git`
        pueue # 17m, manage sequential/parallel long-running tasks, `pueued`, `pueue add ls; pueue add sleep 100; pueue; pueue log`
        onefetch # 33m, like neofetch but stats for git repos, shows name, description, HEAD, version, languages, deps, authors, changes, contributors, commits, LOC, size, license
        xh # 18m, faster httpie in Rust, but only subset of commands, ex: xh httpbin.org/post name=ahmed age:=24; xh :3000/users -> GET http://localhost:3000/users
        tailspin # 11m, automatic log file highligher, supports numbers, dates, IP-addresses, UUIDs, URLs and more; pipe to `tspin`
        spacer # 8m, insert spacers with datetime+duration when command output stops, default is 1s, `tail -f some.log | spacer --after 5` (only after 5s instead); `log stream --predicate 'process == "Google Chrome"' | spacer`; 'If you're the type of person that habitually presses enter a few times in your log tail to know where the last request ended and the new one begins, this tool is for you!' :)
    )

    for package in "${packages[@]}"; do
        install_cargo_package "$package"
    done
}

main

