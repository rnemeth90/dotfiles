#!/bin/bash
# Install mizu

echo ''
echo "Now installing mizu..."
echo ''

cd ~/bin
curl -Lo mizu https://github.com/up9inc/mizu/releases/latest/download/mizu_linux_amd64
sudo chmod 755 mizu