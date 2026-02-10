<#
.SYNOPSIS
Remove-MailboxContents.ps1 - This script will delete email items within a mailbox. The "Search-Mailbox" cmdlet has a
search limit of 10,000 items. This script will loop through a specified number of times, deleting up to 10,000
emails each time.

.OUTPUTS
Results are output to screen and logfile

.PARAMETER Date
This parameter specifies the oldest email you would like to search for and delete. For example, specifying a date of
05.20.2017 will delete all emails that are older than May 20th, 2017.

.Parameter Mailbox
This parameter specifies the mailbox you would like to search.

.Parameter RecursionCount
This parameter specifies the number of times you would like the "Search-Mailbox" cmdlet to run. This cmdlet is limited to
searching for 10,000 email items per run. If you needed to delete 50,000 emails, you would set the RecursionCount parameter
to 5.

.EXAMPLE
Remove-MailboxContents -Mailbox jdoe@geekyryan.com -Date 05.20.2017 -RecursionCount 5

.NOTES
Author: Ryan Nemeth - RyanNemeth@live.com
Site: http://www.geekyryan.com

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

Change Log
V1.00, 03/08/2017 - Initial version
V1.10, 03/17/2020 - Updated for new Exchange Online PS Module
#>


# Parameter help description
param(
    [Parameter(Mandatory=$true)]
    [String]$Date,
    [Parameter(Mandatory=$true)]
    [String]$Mailbox,
    [Parameter(Mandatory=$true)]
    [String]$RecursionCount
)

$logfile = ".\Remove-MailboxContents.log"

#Connect to Exchange Online if not already connected
#$checkConn = Get-PSSession
#if($checkConn.ComputerName -ne "outlook.office365.com"){
#    Connect-ExchangeOnline -EnableErrorReporting -LogDirectoryPath $ENV:TEMP\exchange-ps.log -LogLevel All
#}

Connect-ExchangeOnline

function writeLog(){
    param(
        [String]$value1
    )

    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 | Out-File $logfile -Append

}

$i = 1
do{
    Write-Host "Iteration # $i" -ForegroundColor Green
    writeLog "**************"
    writelog "Iteration # $i"
    writeLog "**************"
    Search-Mailbox -Identity $Mailbox -SearchQuery "Received<$($Date)" -DeleteContent -Force | Tee-Object -File ".\Remove-MailboxContents.log" -Append
    #Clear-Host
    $i++
    }
while ($i -le $RecursionCount)
