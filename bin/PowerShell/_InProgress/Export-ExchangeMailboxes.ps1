<#
    .SYNOPSIS 
     Creates a .pst backup of all mailboxes found on an Exchange server
    .PARAMETER Mode
     The script accepts one parameter that is mandatory. The
     parameter specifies whether the script runs in "test mode" or "real mode". Test mode does not actually make any 
     modifications. Real mode does. To use real mode, pass the value "real" to the "-mode" parameter. To use test mode, 
     pass "test" to the "-mode" parameter.
    .EXAMPLE
     Export-ExchangeMailboxes -mode Test
    .EXAMPLE
     Export-ExchangeMailboxes -Mode Real
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
    .EXAMPLE
     Export-ExchangeMailboxes [-Mode <String>]
#>


Param(
    [Parameter(Mandatory=$false,Position=1)]
    [string]$Mode
)
Param(
    [Parameter(Mandatory=$false,Position=2)]
    [string]$SRVPath
)
Param(
    [Parameter(Mandatory=$false,Position=3)]
    [string]$RESULT
)

$path = "\\dynamicmail\exports"
new-managementRoleAssignment -role "Mailbox Import Export" -user "%userDomain%\%username%"

#The Test Mode Function
function testMode{
    $mailbox = get-mailbox
    foreach($mb in $mailbox){
        New-MailboxExportRequest -filepath $path\$mb.pst -mailbox $mb -whatif
    }   
}


#The Real Mode Function
function realMode{
    try{
        $mailbox = get-mailbox
        foreach($mb in $mailbox){
            New-MailboxExportRequest -filepath $path\$mb.pst -mailbox $mb
        }
    }
    catch{
        
    } 
}

function result{
    $runCount = Get-MailboxExportRequest | where status -eq "InProgress" | measure
    $doneCount = Get-MailboxExportRequest | where status -eq "Completed" | measure
    $failCount = Get-MailboxExportRequest | where status -eq "Failed" | measure
    Write-Host "Finished Exports: " $doneCount.Count -ForegroundColor Yellow
    Write-Host "Running Exports: " $runCount.Count -ForegroundColor Yellow
    Write-Host "Failed Exports: " $failCount.Count -ForegroundColor Yellow

}

if($mode -eq "test"){
    testMode
}
elseif($mode -eq "real"){
    realMode
}
elseif($mode -eq "result"){
    result
}
else{
    Write-Host "Parameter not recognized. Please try again." -ForegroundColor Red
}