<#
    .SYNOPSIS 
     Creates a backup of all Active Directory DNS Zones
    .PARAMETER Mode
     This script accepts one parameter: $Path. Though, this parameter does not currently work due to a bug
     in the "Export-DnsSeverZone" cmdlet. All backups will be placed in the default path of "c:\windows\system32\dns"
    .EXAMPLE
     Backup-AllDnsZones.ps1
    .Example
     Backup-AllDnsZones.ps1 -Path <Path to export zones to>
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 2017.04.26.01
#>

Param(
    [Parameter(Mandatory=$False)]
    [string]$Path
)

$computerName = $env:computerName
$date = get-date -format M.d.yyyy 
$installState = Get-WindowsFeature -Name DNS | Select-Object Installed
$logpath = "c:\DNSBackuplogs"
$logFile = "Backup-AllDnsZones.log"
$mailServer = ""
$sender = ""
$recipient = ""
$zones = Get-DnsServerZone | Where-Object IsReverseLookupZone -NE True -ErrorAction SilentlyContinue
#$Path = $Path

New-Item -Type Directory -Path $logpath\$date+$computername -Force 

Start-Transcript -Path $logpath\$date+$computername\$logFile -Append

<#
if(!(Test-Path $Path)){
    New-Item -ItemType Directory -Path $Path
}
#>

#Check if DNS Server is installed
if (!($installState.Installed -eq $True)){
    Write-Host "DNS Server is not installed. Cannot continue..."   
}

#Import Group Policy Module
try {
    Import-Module DnsServer 
}
catch [System.Exception] {
    Write-Host "Unable to import the DNS Server Powershell Module" -ForegroundColor Red
}

#Create DNS Zone Backup
foreach($zone in $zones){
    Write-Host "Exporting Zones..." -ForegroundColor Yellow
    $zonename = $zone.zonename
    Export-DnsServerZone -Name $zonename -Filename $zonename.txt -ErrorAction SilentlyContinue
}
Stop-Transcript

#Add
#Add functionality for email reports if running as a scheduled task