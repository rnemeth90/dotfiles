#!/bin/bash
# Install Terraform

echo ''
echo "###############################"
echo "# ow adding terraform sources #"
echo "###############################"
echo ''
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update
sudo apt install terraform -y