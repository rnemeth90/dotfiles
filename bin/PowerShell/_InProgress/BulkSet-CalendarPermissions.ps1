<#
.SYNOPSIS
BulkSet-CalendarPermissions.ps1 - Grant a user access rights to multiple calendars

.DESCRIPTION 
This Powershell script is effective when you have one user that you want to grant 
access rights to multiple other users' calendars. For example, the HR person wants Owner
access to all employee calendars. 

.OUTPUTS
Results are output to a text log file and to screen. 

.PARAMETER File

.PARAMETER Identity

.PARAMETER Permissions


.EXAMPLE
.\Add-SMTPAddresses.ps1 -Domain office365bootcamp.com
This will perform a test pass for adding the new alias@office365bootcamp.com as a secondary email address
to all mailboxes. Use the log file to evaluate the outcome before you re-run with the -Commit switch.

.EXAMPLE
.\Add-SMTPAddresses.ps1 -Domain office365bootcamp.com -MakePrimary
This will perform a test pass for adding the new alias@office365bootcamp.com as a primary email address
to all mailboxes. Use the log file to evaluate the outcome before you re-run with the -Commit switch.

.EXAMPLE
.\Add-SMTPAddresses.ps1 -Domain office365bootcamp.com -MakePrimary -Commit
This will add the new alias@office365bootcamp.com as a primary email address
to all mailboxes.

.NOTES
Written by: Ryan Nemeth

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

For more Exchange Server tips, tricks and news
check out Exchange Server Pro.

* Website:	http://exchangeserverpro.com
* Twitter:	http://twitter.com/exchservpro

Change Log
V1.00, 21/05/2015 - Initial version
#>



param(
    [Parameter(Mandatory=$True)]
    [String]$File,
    [Parameter(Mandatory=$True)]
    [String]$Identity,
    [Parameter(Mandatory=$True)]
    [String]$Permission
)

<#

#Variables
$logfile = ".\playWithFunctions.log"
$checkConn = Get-PSSession

#Functions
function ImportCSV()
{
    $users = Import-Csv $File
    return $users.username
}

function WriteLog()
{
    param
    (
        [String]$value1
    )

    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 | Out-File $logfile -Append
}

function GetCurrentPermission($mbuser)
{
    $currentPerms = Get-MailboxFolderPermission -Identity ${mbuser}:\Calendar -User $Identity
    Write-Host "$currentPerms.User currently has $currentPerms.AccessRights to $mbuser calendar"
    WriteLog $currentPerms
}

#Connect to Exchange Online if not already connected
if($checkConn.ComputerName -ne "ps.outlook.com")
{
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential (Get-Credential) -Authentication Basic -AllowRedirection
    Import-PSSession $session
}

ImportCSV

#>

$users = get-content $File

foreach($user in $users) 
{
    #GetCurrentPermission($user)
    #$settingPerms = 
    Add-MailboxFolderPermission -Identity ${user}:\calendar -User $Identity -AccessRights $Permission
    #WriteLog $settingPerms
    #Write-Host "Granting $Identity $Permission access to $user mailbox"
}