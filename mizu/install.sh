#!/bin/bash
# Install mizu

echo ''
info "Now installing mizu..."
echo ''

cd ~/.dotfiles/bin
curl -Lo mizu https://github.com/up9inc/mizu/releases/latest/download/mizu_linux_amd64
mv mizu_linux_amd64 mizu
sudo chmod 755 mizu