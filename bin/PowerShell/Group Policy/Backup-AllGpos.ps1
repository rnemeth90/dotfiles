
<#
    .SYNOPSIS 
     Creates a backup of all GPO's and uploads them to a remote SMB share. This script can also be run as a scheduled task.
    .PARAMETER Mode
     This script accepts two parameters. The Server parameter is used to specify the server where you would
     like to backup the GPOs to. The Share parameter is used to specify the share located on the server that the GPOs will be backed up to. 
    .EXAMPLE
     Backup-AllGpos -Server myServer -Share myShare
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Server,
    [Parameter(Mandatory=$true)]
    [string]$Share
)

$computerName = $env:computerName
$date = get-date -format M.d.yyyy 
$installState = Get-WindowsFeature -Name GPMC | Select-Object Installed
$logFile = "Backup-AllGpos.log"
$mailServer = ""
$sender = ""
$recipient = ""


New-Item -Type directory -Path \\$server\$share\$date+$computername -Force 

Start-Transcript -Path \\$server\$share\$date+$computername\$logFile -Append

#Identify if Group Policy Management Powershell module is already installed. Attempt to install if not found.
try {
    if ($installState -eq $false) {
    Write-Host 'GPMC not found. Attempting to install now...' -ForegroundColor Yellow
    Install-WindowsFeature -Name GPMC
    }
    else {
        Write-Host 'GPMC already installed. Continuing...' -ForegroundColor Yellow
    }
}
catch [System.Exception] {
    Write-Host "Group Policy Management Module for Powershell cannot be found and cannot be installed. Please try again." -ForegroundColor Red    
}

#Import Group Policy Module
try {
    Import-Module grouppolicy 
}
catch [System.Exception] {
    Write-Host "Unable to import Group Policy Powershell Module" -ForegroundColor Red
}

#Create GPO Backup
try {
    Backup-Gpo -All -Path \\$server\$share\$date+$computername
}
catch [System.Exception] {
    Write-Host "Unable to create GPO Backup. Verify the path you specified is correct." -ForegroundColor Red
}

Stop-Transcript

#Send Email Notification on Completion
Send-MailMessage -To $recipient -From $sender -SmtpServer $mailServers -BodyAsHtml 