#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "$DOT/utils/utils.sh"

install_fonts() {
    print_in_purple "\n • Install Nerd Fonts\n\n"

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

    # Check for required tools
    if ! command -v curl &>/dev/null || ! command -v unzip &>/dev/null; then
        print_in_red "\n [✖] curl and/or unzip are not installed. Please install them first.\n"
        exit 1
    fi

    # Create fonts directory if it doesn't exist
    if [[ ! -d "$fonts_dir" ]]; then
        mkdir -p "$fonts_dir"
    fi

    # Download and install fonts
    for font in "${fonts[@]}"; do
        zip_file="${font}.zip"
        download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"

        if [[ -d "${fonts_dir}/${font}" ]]; then
            print_in_green "\n [✔] $font is already installed. Skipping...\n"
            continue
        fi

        print_in_yellow "\n • Downloading and installing $font...\n"
        if curl -L -o "$zip_file" "$download_url"; then
            unzip -o "$zip_file" -d "$fonts_dir/$font" &>/dev/null
            rm "$zip_file"
            print_in_green "\n [✔] Successfully installed $font.\n"
        else
            print_in_red "\n [✖] Failed to download $font. Skipping...\n"
            continue
        fi
    done

    # Remove unnecessary files
    find "$fonts_dir" -name '*Windows Compatible*' -delete

    # Set permissions and refresh font cache
    chmod -R 775 "$fonts_dir"
    fc-cache -fv "$fonts_dir" &>/dev/null

    print_in_green "\n • All fonts installed and font cache updated!\n"
}

main() {
    print_in_purple "\n • Start setting up OS theme...\n\n"
    install_fonts
}

main
