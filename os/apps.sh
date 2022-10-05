#!/bin/bash

declare DOT=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "$DOT/setup/utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_tlp_battery_management() {

        print_in_purple "\n • Installing tlp battery management \n\n"

        sudo dnf install -y tlp tlp-rdw

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_multimedia_codecs() {

        print_in_purple "\n • Installing multimedia codecs... \n\n"

        sudo dnf groupupdate sound-and-video
        sudo dnf install -y libdvdcss
        sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
        sudo dnf install -y lame\* --exclude=lame-devel
        sudo dnf group upgrade --with-optional Multimedia

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_VSCode_and_set_inotify_max_user_watches() {

        print_in_purple "\n • Installing VSCode \n\n"

        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf check-update
        sudo dnf install -y code

        echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
        sudo sysctl -p

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_VLC() {

        print_in_purple "\n • Installing VLC \n\n"

        sudo dnf install -y vlc

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_terminator() {

        print_in_purple "\n • Installing terminator \n\n"

        sudo dnf install -y terminator

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_docker() {

        print_in_purple "\n • Installing docker \n\n"

        sudo dnf install -y docker

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_mutt() {

        print_in_purple "\n • Installing mutt \n\n"

        sudo dnf install -y mutt

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_virtualbox() {

        print_in_purple "\n • Installing Virtual Box \n\n"

        sudo dnf install -y virtualbox

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_ulauncher() {

        print_in_purple "\n • Installing Ulauncher \n\n"

        sudo dnf install -y ulauncher

        # https://github.com/Ulauncher/Ulauncher/wiki/Hotkey-In-Wayland
        sudo dnf install -y wmctrl

}

# - - - - - - - - - - - - - - - - - - - - -   - - - - - - - - - - - - - -

# Google Chrome

install_chrome() {

        print_in_purple "\n • Installing Chrome \n\n"

        sudo dnf config-manager --set-enabled google-chrome

        sudo dnf install -y google-chrome-stable

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Brave Browser

install_brave() {

    print_in_purple "\n • Installing Brave \n\n"

    sudo dnf install dnf-plugins-core

    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/

    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

    sudo dnf install brave-browser
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Helm

install_helm() {
    print_in_purple "\n • Installing helm \n\n"
    sudo dnf install helm -y
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# htop

install_htop() {
    print_in_purple "\n • Installing htop \n\n"
    sudo dnf install htop -y

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_nmap() {
    print_in_purple "\n • Installing nmap \n\n"
    sudo dnf install nmap -y

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_wireshark() {
    print_in_purple "\n • Installing wireshark \n\n"
    sudo dnf install wireshark -y

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_tor() {
    print_in_purple "\n • Installing tor \n\n"
    sudo dnf install tor -y

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


# Kubectl

install_kubectl() {

print_in_purple "\n • Installing kubectl \n\n"

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubectl
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_mizu() {

    print_in_purple "\n • Installing mizu \n\n"

    print_in_purple "\n • Installing mizu \n\n"
    curl -Lo ~/bin/mizu https://github.com/up9inc/mizu/releases/latest/download/mizu_linux_amd64
    sudo chmod 755 ~/bin/mizu
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_random() {

    print_in_purple "\n • Installing everything else... \n\n"

    sudo dnf install -y \
    apt-transport-https \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    dnsenum \
    figlet \
    file \
    gnupg \
    golang \
    jq \
    kubetail \
    kubecolor \
    nmap \
    neofetch \
    net-tools \
    nfs-common \
    nodejs \
    python3-pip \
    ranger \
    software-properties-common \
    speedtest-cli \
    wapiti
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_terraform() {

    print_in_purple "\n • Installing terraform... \n\n"

    sudo dnf install -y dnf-plugins-core -y
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/$release/hashicorp.repo
    sudo dnf install terraform -y
}

install_ranger() {

    print_in_purple "\n • Installing ranger... \n\n"
    sudo dnf install ranger -y
}



# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {

        install_tlp_battery_management

        install_multimedia_codecs

        install_VSCode_and_set_inotify_max_user_watches

        install_VLC

        install_ulauncher

        install_chrome

        install_brave

        install_docker

        install_helm

        install_htop

        install_kubectl

        install_mizu

        install_mutt

        install_random

        install_ranger

        install_terminator

        install_terraform

        install_virtualbox

        install_wireshark

        install_nmap

        install_tor
}

main
