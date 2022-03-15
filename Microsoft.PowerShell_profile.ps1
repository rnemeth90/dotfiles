Import-Module $env:SystemDrive:\repos\dotfiles\functions\Install.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\Linuxize_me.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\conversions.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\env.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\misc.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\git.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\shutup.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\terraform.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\helm.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\k8s.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\docker.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\az.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\work.ps1
Import-Module $env:SystemDrive:\repos\dotfiles\functions\navigation.ps1

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