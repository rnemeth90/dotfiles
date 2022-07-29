#!/bin/bash

# Install oh my bash
echo ''
echo "#############################"
echo "# Now installing oh my bash #"
echo "#############################"
echo ''
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"


# Bash color scheme
echo ''
echo "##################################################"
echo "# Now installing solarized dark WSL color scheme #"
echo "##################################################"
echo ''
wget https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.256dark
mv dircolors.256dark .dircolors