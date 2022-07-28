#!/usr/bin/env bash

# Install oh my bash
echo ''
read -p "Do you want to install oh-my-bash? y/n " -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]
  then
  echo ''
  echo "Now installing oh my bash..."
  echo ''
  sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
fi

# Bash color scheme
echo ''
echo "Now installing solarized dark WSL color scheme..."
echo ''
wget https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.256dark
mv dircolors.256dark .dircolors