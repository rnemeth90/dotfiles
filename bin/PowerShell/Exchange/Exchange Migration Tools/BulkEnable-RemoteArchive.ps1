<#
    .SYNOPSIS 
     This script enables the archive mailbox for multiple users in Exchange Online. A .csv file containing the identies of the mailboxes
     in question is required in the same directory as the script.  
    .PARAMETER Mode
     The script accepts one parameter: Mode. There are two options: "real" and "test". Test mode is basically running the script in "WhatIf"
     mode. Real mode will make modifications to the mailboxes. 
    .EXAMPLE
     BulkEnable-RemoteArchives -Mode Real
    .EXAMPLE
     BulkEnable-RemoteArchives -Mode Test
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>


param(
    [Parameter(Mandatory=$True)]
    [string]$Mode
)

$ScriptName = "BulkEnable-RemoteArchives.ps1"

$mbs = Import-Csv .\mailboxes.csv

if($mode -eq "Test"){
    foreach($mb in $mbs){
        Enable-RemoteMailbox -Identity $mb -Archive -Whatif
    }
}
elseif($mode -eq "Real"){
    foreach($mb in $mbs){
        Enable-RemoteMailbox -Identity $mb -Archive
    }
}
else{
    Get-Help $ScriptName
}