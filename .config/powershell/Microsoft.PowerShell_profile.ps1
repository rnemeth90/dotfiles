# Environment Variables
$env:EDITOR = "nvim"
$env:TERM = "xterm-256color"

Import-Module .\functions\conversions.ps1
Import-Module .\functions\env.ps1
Import-Module .\functions\misc.ps1
Import-Module .\functions\git.ps1
Import-Module .\functions\terraform.ps1
Import-Module .\functions\helm.ps1
Import-Module .\functions\kubernetes.ps1
Import-Module .\functions\docker.ps1
Import-Module .\functions\az.ps1
Import-Module .\functions\work.ps1
Import-Module .\functions\navigation.ps1
Import-Module .\functions\aliases.ps1
