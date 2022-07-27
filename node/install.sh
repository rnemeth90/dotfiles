#!/bin/bash
# Install nodejs and npm

echo ''
info "Now installing node..."
echo ''

sudo apt install nodejs -y
sudo apt install npm -y

if test ! $(which spoof)
then
  sudo npm install npm -g
  sudo npm install spoof -g
  sudo npm install typescript -g
fi
