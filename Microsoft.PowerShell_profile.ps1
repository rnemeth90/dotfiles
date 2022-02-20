Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\Install.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\Linuxize_me.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\conversions.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\env.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\misc.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\git.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\shutup.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\terraform.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\helm.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\k8s.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\docker.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\az.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\work.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\build\windows\functions\navigation.ps1

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

set-alias d docker
set-alias ll Get-ChildItem
set-alias unzip expand-archive
#Set-Alias -Name git-yolo -Value "git commit -am $(curl -s http://whatthecommit.com/index.txt)" -Force

#Import-Module DockerCompletion
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt -Theme emodipt

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward