Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

$username = $env:USERNAME

# Downloading Choco
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# close and spin up a new terminal
choco install git python -y
choco feature enable -n allowGlobalConfirmation


# Automatic
New-item -Type Directory -Path $env:SystemDrive\repos
cd $env:SystemDrive\repos
git clone https://github.com/rnemeth90/dotfiles.git
cd $env:SystemDrive\repos\dotfiles\
git checkout powershell


# New-Item -Path $env:USERPROFILE\.gitconfig -ItemType SymbolicLink -Value $env:SystemDrive\Repos\dotfiles\.config\.gitconfig

New-Item -Path c:\users\$($Env:USERNAME)\Documents\PowerShell\Microsoft.Powershell_Profile.ps1 -ItemType SymbolicLink  -Value $env:SystemDrive\repos\dotfiles\Microsoft.PowerShell_profile.ps1
New-Item -Path c:\users\$($Env:USERNAME)\Documents\PowerShell\Microsoft.VSCode_profile.ps1 -ItemType SymbolicLink -Value $env:SystemDrive\repos\dotfiles\Microsoft.VSCode_profile.ps1

#New-Item -Path "C:\Users\Ryan.Nemeth\AppData\Local\Packages\KaliLinux.54290C8133FEE_ey8k8hqnwqnmg\LocalState\rootfs\home\ryan\.bashrc" -ItemType SymbolicLink -Value "C:\repos\dotfiles\build\linux\.bashrc"


# Install WSL
cd C:\Repos\dotfiles\build\windows\helpers
.\wsl.ps1 install

# GO!
#./go.ps1

