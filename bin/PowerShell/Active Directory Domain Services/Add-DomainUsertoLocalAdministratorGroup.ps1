<#
    .SYNOPSIS 
     Adds a list of domain users to the local administrators group on a computer
    .EXAMPLE
     Add-DomainUsertoLocalAdministratorsGroup
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
    This script allows the user to load a csv file named "users.csv" with a list of usernames, and then adds
    the specified users to the local administrators group. 
    Version 1.0
#>

Write-Host "Creating variables"
$users = import-csv -Path .\users.csv
$domain = "contoso"

Write-Host "Entering loop"
foreach($user in $users){
    Write-Host "Adding Users"
    "net localgroup administrators $domain\$user /add"
    Write-Host "Adding user " $user "to local administrators group"
}
Write-Host "Script executed successfully"