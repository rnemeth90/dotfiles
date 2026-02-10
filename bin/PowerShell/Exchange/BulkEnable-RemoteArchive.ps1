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
$logfile = $ScriptName
$mbs = Import-Csv .\mailboxes.csv

function writeLog(){
    param(
        [String]$value1
    )

    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 | Out-File $logfile -Append

}

if($mode -eq "Test"){
    foreach($mb in $mbs){
        Enable-RemoteMailbox -Identity $mb -Archive -Whatif        
        Write-Host "TEST MODE: Creating contact for $mb" -ForegroundColor Green
        writeLog "****"
        writeLog "**** TEST MODE: Enabling Online Remote Archive for $mb"
        writeLog "**** TEST MODE: Ran on $computerName by $username"
    }
}
elseif($mode -eq "Real"){
    foreach($mb in $mbs){
        Enable-RemoteMailbox -Identity $mb -Archive
        Write-Host "Creating contact for $mb" -ForegroundColor Green
        writeLog "****"
        writeLog "**** Enabling Online Remote Archive for $mb"
        writeLog "**** Ran on $computerName by $username"
    }
}
else{
    Get-Help $ScriptName
}