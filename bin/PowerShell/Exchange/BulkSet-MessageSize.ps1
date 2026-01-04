<#
    .SYNOPSIS 
     This script sets the maximum message size for mailboxes in Exchange Online. 
    .PARAMETER 
     The script accepts three parameters that are mandatory. The "MessageSize" parameters should be passed an
     integer value in megabytes. The "Mode" parameter should be passed a string value of "Test" or "Real". 
    .EXAMPLE
     BulkSet-MessageSize -Mode Test -MaxSendSize 150 -MaxReceiveSize 150
    .EXAMPLE
     BulkSet-MessageSize -Mode Real -MaxSendSize 150 -MaxReceiveSize 150
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
    .EXAMPLE
     BulkSet-MessageSize [-Mode <String>] [-MessageSize <IntegerMB>]
#>

param(
    [parameter(Mandatory=$True, Position=1)]
    [string]$Mode
)
param(
    [parameter(Mandatory=$True, Position=2)]
    [string]$MaxReceiveSize
)
param(
    [parameter(Mandatory=$True, Position=3)]
    [string]$MaxSendSize
)

#Connect to Exchange Online
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential (Get-Credential) -Authentication Basic -AllowRedirection
Import-PSSession $session


function testMode{
    Get-Mailbox | Set-Mailbox -MaxSendSize $MaxSendSize -MaxReceiveSize $MaxReceiveSize -whatif
}

function realMode{
    $mailboxes = Get-Mailbox 
    Set-Mailbox -identity $mailboxes.identity -MaxSendSize $MaxSendSize -MaxReceiveSize $MaxReceiveSize
}

if($mode -eq "test"){
    testMode
}
elseif($mode -eq "real"){
    realMode
}
else{
    Write-Host "Parameter not recognized. Please try again." -ForegroundColor Red
}