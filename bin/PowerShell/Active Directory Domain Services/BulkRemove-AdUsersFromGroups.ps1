Param(
   [Parameter(Mandatory=$True)]
   [string]$Mode,
   [Parameter(Mandatory=$True)]
   [string]$Group
)

$users = Get-Content .\users.txt
#$group = "EV Standard Provisioning Group"

if ($mode -eq "Test"){
    foreach($user in $users){
            Remove-ADGroupMember -Identity $Group -Members $user -WhatIf
    }
}
elseif($Mode -eq "Real"){
    foreach($user in $users){
            Remove-ADGroupMember -Identity $Group -Members $user
    }
}
else {
    Write-Host "You did something wrong. Please try again." -ForegroundColor Red
}