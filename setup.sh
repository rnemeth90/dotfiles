#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" &&
    . "setup/utils.sh" && . "os/settings.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_extensions_and_pkg_managers() {
    print_in_purple "\n • Installing basic extensions and pkg managers \n\n"
    ./os/arch/extensions_and_pkg_managers.sh
    print_in_green "\n • Finished installing basic extensions and pkg managers! \n\n"
    sleep 5
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

init_setup() {
    print_in_purple "\n • Starting initial Linux setup \n\n"
    ./os/arch/init.sh
    print_in_green "\n • Initial setup done! \n\n"
    sleep 5
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bash_and_git_configs() {
    print_in_purple "\n • Create bash and git files with symlinks + local config files for each \n\n"
    /bin/bash -c "$(curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash)"
    ./setup/create_symbolic_links.sh
    ./shell/create_local_shellconfig.sh
    ./git/create_local_gitconfig.sh
    print_in_green "\n • Bash and git configs done! \n\n"
    sleep 5
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

create_and_set_github_ssh_key() {
    ./git/set_github_ssh_key.sh
    print_in_green "\n • Github ssh key creation done! \n\n"
    sleep 5
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

setup_os_theme_and_terminal_style() {
    print_in_purple "\n • Setting up OS theme and terminal tweaks \n\n"
    ./os/theme/main.sh
    print_in_green "\n Theme and terminal setup done! \n\n"
    sleep 5
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_apps() {
    print_in_purple "\n • Installing applications \n\n"
    ./os/apps.sh
    print_in_green "\n Apps installed! \n\n"
    sleep 5
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_dev_packages() {
    print_in_purple "\n • Installing dev packages \n\n"
    ./os/dev_packages.sh
    print_in_green "\n Dev packages installed! \n\n"
    sleep 5
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

linux_setup_final() {
    source ~/.bashrc
    # final tweaks
    print_in_green "\n • All done! Remember to set your fonts with lxappearance! \n"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    install_extensions_and_pkg_managers
    init_setup
    bash_and_git_configs
    setup_os_theme_and_terminal_style
    install_apps
    install_dev_packages
    linux_setup_final
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Allow calling single functions in script and run main if nothing is specified
"$@"

if [ "$1" == "" ]; then
    main
fi
