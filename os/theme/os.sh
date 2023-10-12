#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/setup/utils.sh"
$()
install_fonts() {
    print_in_purple "\n • Install Fonts\n\n"

    declare -a fonts=(
        BitstreamVeraSansMono
        CodeNewRoman
        DroidSansMono
        FiraCode
        FiraMono
        Go-Mono
        Hack
        Hermit
        JetBrainsMono
        Meslo
        Noto
        Overpass
        ProggyClean
        RobotoMono
        SourceCodePro
        SpaceMono
        Ubuntu
        UbuntuMono
    )

    version='2.1.0'
    fonts_dir="${HOME}/.local/share/fonts"

    if [[ ! -d "$fonts_dir" ]]; then
        mkdir -p "$fonts_dir"
    fi

    for font in "${fonts[@]}"; do
        zip_file="${font}.zip"
        download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
        echo "Downloading $download_url"
        curl -O "$download_url"
        unzip "$zip_file" -d "$fonts_dir"
        rm "$zip_file"
    done

    find "$fonts_dir" -name '*Windows Compatible*' -delete
    sudo chmod -R 775 /home/ryan/.local/share/fonts
}

main() {
    print_in_purple "\n • Start setting up OS theme...\n\n"
    install_fonts
}

main
