param(
    [bool]$testMode,
    [String]$Path
)

$users = get-content $Path


if($testMode -eq $True){
    foreach($user in $users){
        Remove-ADUser -Identity $user -WhatIf
        write-host "TEST MODE: Removing User" $user
    }
}
else{
    foreach($user in $users){
        Remove-ADUser -Identity $user
        write-host "Removing User" $user
    }
}