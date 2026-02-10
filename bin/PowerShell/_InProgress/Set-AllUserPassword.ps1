Connect-MsolService

$password = Read-Host "New Password"
Get-MsolUser |%{Set-MsolUserPassword -userPrincipalName $_.UserPrincipalName –NewPassword $password -ForceChangePassword $false}
#write-host "Resetting password to" $password "for user:" $_.UserPrincipalName
