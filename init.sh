#!/bin/bash

# Update pkg lists
echo "Updating package lists..."
sudo apt update



# Install Helm
echo ''
echo "Now adding helm sources..."
echo ''
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Install kubectl
echo ''
echo "Now adding kubectl sources..."
echo ''
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Terraform
echo ''
echo "Now adding terraform sources..."
echo ''
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Install azurecli
echo ''
echo "Now installing AzureCli sources..."
echo ''
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install everything else
echo ''
echo "Now installing everything else..."
echo ''
sudo apt install -y jq kubetail nmap nodejs golang ranger neofetch figlet kubectl helm  gnupg software-properties-common curl \
                    apt-transport-https ca-certificates curl terraform python3-pip nfs-common bash-completion speedtest-cli git

echo ''
echo "Now configuring git-completion..."
GIT_VERSION=`git --version | awk '{print $3}'`
URL="https://raw.github.com/git/git/v$GIT_VERSION/contrib/completion/git-completion.bash"
echo ''
echo "Downloading git-completion for git version: $GIT_VERSION..."
if ! curl "$URL" --silent --output "$HOME/.git-completion.bash"; then
	echo "ERROR: Couldn't download completion script. Make sure you have a working internet connection." && exit 1
fi

# Bash color scheme
echo ''
echo "Now installing solarized dark WSL color scheme..."
echo ''
wget https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.256dark
mv dircolors.256dark .dircolors

# Pull down personal dotfiles
echo ''
read -p "Do you want to use rnemeth's dotfiles? y/n " -n 1 -r
echo ''
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo ''
	echo "Now pulling down rnemeth's dotfiles..."
	git clone https://github.com/rnemeth90/dotfiles.git ~/.dotfiles
	echo ''
	cd $HOME/.dotfiles && echo "switched to .dotfiles dir..."
	echo ''
  chmod a+x $HOME/.dotfiles/script/bootstrap
	echo "Now configuring symlinks..." && $HOME/.dotfiles/script/bootstrap
    if [[ $? -eq 0 ]]
    then
        echo "Successfully configured your environment with rnemeth's dotfiles..."
    else
        echo "rnemeth's dotfiles were not applied successfully..." >&2
fi
else
	echo ''
    echo "You chose not to apply rnemeth's dotfiles. You will need to configure your environment manually..."
	echo ''
	echo "Setting defaults for .bashrc..."
	echo ''
	echo "source $HOME/.git-completion.bash" >> ${ZDOTDIR:-$HOME}/.bashrc && echo "added git-completion to .bashrc..."
fi

# # Install oh my bash
# echo ''
# echo "Now installing oh my bash..."
# echo ''
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

echo ''
echo '	Done! Please reboot your computer for changes to be made.'