<#
    .SYNOPSIS 
     Removes users specified in a CSV file. The CSV file must be named "users.csv" and exist within the same directory
     as the script. The column name in the CSV must be "UPN". 
    .PARAMETER Mode
     The script accepts one parameter that is mandatory. The
     parameter specifies whether the script runs in "test mode" or "real mode". Test mode does not actually make any 
     modifications. Real mode does. To use real mode, pass the value "real" to the "-mode" parameter. To use test mode, 
     pass "test" to the "-mode" parameter.
    .EXAMPLE
     BulkRemove-Office365Accounts -Mode Test
    .EXAMPLE
     BulkRemove-Office365Accounts -Mode Real
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
    .EXAMPLE
     BulkRemove-Office365Accounts.ps1 [-Mode <String>]
#>

param(
    [String]$dagName,
    [String]$dagIpAddr,
    [String]$dagWitnessName,
    [String]$dagWitnessLocation,
    [String]$dagMembers,
    [String]$domainName
)

$domainName = 

#Check if AD Module Exists, if not install it
$stat = Get-Module -ListAvailable -Name ActiveDirectory

if($stat -eq $null){
    Write-Host "Powershell AD Module Not Found. Installing Now...." -ForegroundColor Yellow
    Clear-Host
    Install-WindowsFeature -Name RSAT-AD-Powershell
}
else{
    Import-Module ActiveDirectory
}

#Create CNO, Assign Exchange Trusted Subsystem full access, disable

$cnoPath = "AD:\cn=$dagName,
New-ADComputer -Name $dagName -SAMAccountName $dagName -Enabled $false
Set-ADObject  -ProtectedFromAccidentalDeletion $true


#Create DAG, configure IP address, name, and witness

#Add Members to DAG
