#!/bin/bash
# Install everything else

echo ''
echo "Now installing everything else..."
echo ''
sudo apt install -y jq kubetail nmap nodejs golang ranger neofetch figlet gnupg software-properties-common curl \
                    apt-transport-https ca-certificates curl python3-pip nfs-common bash-completion speedtest-cli git \
                    nikto dnsenum net-tools build-essential curl file 