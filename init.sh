#!/bin/bash

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

# Update pkg lists
echo "Updating package lists..."
sudo apt update
sudo apt install git -y
sudo apt install npm -y

# Pull down personal dotfiles and make links
echo ''
read -p "Do you want to use rnemeth's dotfiles? y/N " -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo ''
	info "Now pulling down rnemeth's dotfiles..."
	git clone https://github.com/rnemeth90/dotfiles.git ~/.dotfiles
	echo ''
	cd $HOME/.dotfiles && echo "switched to .dotfiles dir..."
	echo ''
  chmod a+x $HOME/.dotfiles/script/bootstrap
	info "Now configuring symlinks..." && $HOME/.dotfiles/script/bootstrap
    if [[ $? -eq 0 ]]
    then
        success "Successfully configured your environment with rnemeth's dotfiles..."
    else
        fail "rnemeth's dotfiles were not applied successfully..." >&2
fi
else
	echo ''
    info "You chose not to apply rnemeth's dotfiles. You will need to configure your environment manually..."
	echo ''
	echo "Setting defaults for .bashrc..."
	echo ''
	echo "source $HOME/.git-completion.bash" >> ${ZDOTDIR:-$HOME}/.bashrc && echo "added git-completion to .bashrc..."
fi

# ADD PART FOR INSTALL SCRIPT
# chmod a+x $HOME/.dotfiles/script/installer
echo ''
read -p "Do you want to install software? y/N " -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo ''
  info "Now installing software..."
  echo ''
  cd $HOME/.dotfiles && echo "switched to .dotfiles dir..."
	echo ''
  chmod a+x $HOME/.dotfiles/script/installer && $HOME/.dotfiles/script/installer
  echo ''
fi

# Setup git completion
echo ''
info "Now configuring git-completion..."
GIT_VERSION=`git --version | awk '{print $3}'`
URL="https://raw.github.com/git/git/v$GIT_VERSION/contrib/completion/git-completion.bash"
echo ''
echo "Downloading git-completion for git version: $GIT_VERSION..."
if ! curl "$URL" --silent --output "$HOME/.git-completion.bash"; then
	fail "ERROR: Couldn't download completion script. Make sure you have a working internet connection." && exit 1
fi

echo ''
success '	Done! Please reboot your computer for changes to be made.'