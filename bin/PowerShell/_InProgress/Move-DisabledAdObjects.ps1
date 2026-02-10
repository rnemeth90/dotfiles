<#
    .SYNOPSIS 
     This script will search Active Directory for all disabled computers OR users, and move them to a specified Organizational Unit.
    .PARAMETER DisabledOU
     This parameter defines the target Organization Unit that the objects will be moved to.
    .Parameter Target
     This parameter defines the objects that you want to work with. You can specify "Users" or "Computers"
    .Parameter TestMode
     If this parameter is specified, the script will be run in a test mode. Meaning the script will run, but no actual changes will be made.
    .EXAMPLE
     Move-DisabledAdObjects.ps1 -Target Users -DisabledOu "ou=disabled,ou=users,dc=contoso,dc=com"
    .EXAMPLE
     Move-DisabledAdObjects.ps1 -Target Computers -DisabledOu "ou=disabled,ou=computers,dc=contoso,dc=com"
    .EXAMPLE
     Move-DisabledAdObjects.ps1 -TestMode $true -Target Users -DisabledOu "ou=disabled,ou=users,dc=contoso,dc=com"
    .EXAMPLE
     Move-DisabledAdObjects.ps1 -TestMode $true -Target Computers -DisabledOu "ou=disabled,ou=computers,dc=contoso,dc=com"
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>

param(
    [Parameter(Mandatory=$true)][String]$DisabledOU,
    [ValidateSet("Users","Computers")][String]$Target,
    [bool]$TestMode
)

$stat = Get-Module -ListAvailable -Name ActiveDirectory

if($stat -eq $null){
    Write-Host "Powershell AD Module Not Found. Installing Now...." -ForegroundColor Yellow
    Clear-Host
    Install-WindowsFeature -Name RSAT-AD-Powershell
}
else{
    Import-Module ActiveDirectory
}

if ($Target -eq "Computers") {

    $disabledComps = get-adcomputer -LDAPFilter "(&(&(objectCategory=computer)(objectClass=user)(useraccountcontrol:1.2.840.113556.1.4.803:=2)))"

    if ($TestMode -eq $true) {
        try {
            foreach ($obj in $disabledComps) {
                Move-ADObject -Identity $obj -TargetPath $disabledOU -WhatIf > $null
                Write-Host ""
                Write-host "TEST MODE: Moving" $obj -ForegroundColor green
            }
        }
        catch [System.Exception] {
            
        }
    }
    else{
        try {
            foreach ($obj in $disabledComps) {
                Move-ADObject -Identity $obj -TargetPath $disabledOU > $null
                Write-Host ""
                Write-Host "Moving: " $obj -ForegroundColor Green
            }
        }
        catch [System.Exception] {
            
        }
    }
}

elseif ($Target -eq "Users") {
    
    $disabledUsers = get-aduser -LDAPFilter "(&(&(objectCategory=user)(objectClass=user)(useraccountcontrol:1.2.840.113556.1.4.803:=2)))"

    if ($TestMode -eq $true) {
        try {
            foreach ($obj in $disabledUsers) {
                Move-ADObject -Identity $obj -TargetPath $disabledOU -WhatIf > $null
                Write-Host ""
                Write-host "TEST MODE: Moving" $obj -ForegroundColor Green         
            }
        }
        catch [System.Exception] {
            
        }
    }
    else{
        try {
            foreach ($obj in $disabledUsers) {
                Move-ADObject -Identity $obj -TargetPath $disabledOU > $null
                Write-Host ""
                Write-Host "Moving: " $obj -ForegroundColor Green  
            }
        }
        catch [System.Exception] {
            
        }
    }
}

else {
    Write-host  "ERROR"
}