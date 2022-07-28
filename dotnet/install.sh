# Install dotnet
# curl -sL https://dot.net/v1/dotnet-install.sh | bash

echo ''
echo "Now installing dotnet..."
echo ''
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install dotnet-sdk-6.0
dotnet tool install -g Microsoft.dotnet-httprepl
dotnet tool install -g dotnet-ef