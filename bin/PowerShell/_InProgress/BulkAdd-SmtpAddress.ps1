<#
.SYNOPSIS
BulkAdd-SMTPAddresses.ps1 - Add SMTP addresses for a new domain to multiple (or a single) mailboxes

.DESCRIPTION 
This script will add a new email address to multiple (or a single) Exchange Online mailboxes. 
It is capable of setting the new email address as the primary SMTP address for the mailbox. 
It has the same functionality as an email address policy, but can be used when email address 
policies are not an option. 

.OUTPUTS
Results are output to a text log file.

.PARAMETER DomainName
The domain name for which you would like to add a new email address to the mailbox.

.PARAMETER IsDefault
Specify this parameter if the new email address is to be used as the primary SMTP address.

.PARAMETER AllMailboxes
This parameter specifies that you want to make the change for all mailboxes in the tenant.

.PARAMETER Mailbox
This parameter specifies a single mailbox that you want to make the change for.

.EXAMPLE
BulkAdd-SmtpAddress.ps1 -DomainName contoso.com -AllMailboxes

.EXAMPLE
BulkkAdd-SmtpAddress.ps1 -Domain contoso.com -Mailbox jdoe

.EXAMPLE
BulkAdd-SmtpAddress.ps1 -DomainName contoso.com -AllMailboxes -IsDefault

.EXAMPLE
BulkAdd-SmtpAddress.ps1 -DomainName contoso.com -Mailbox jdoe -IsDefault

.NOTES
Written by: Ryan Nemeth

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

Change Log
V1.0, 05/28/2017 - Initial version
V1.1, 06/26/2017 - Replaced duplicate code with functions
V1.2, 06/26/2017 - Added logging function
#>

param(
    [Parameter(Mandatory=$True)]
    [String]$DomainName,
    [Parameter(Mandatory=$False)]
    [bool]$IsDefault,
    [Parameter(Mandatory=$False)]
    [bool]$AllMailboxes = $true,
    [Parameter(Mandatory=$False)]
    [String]$Mailbox
)

#Null out the variables
$checkConnection = $null
$AllMailboxes = $null
$EmailAddresses = $null
$mb = $null
$NewAddress = $null
$psUrl = "https://ps.outlook.com/powershell"
$logfile = ".\BulkAdd-SMTPAddresses.log"

#Check if connected to Exchange Online PowerShell
#Connect if not already connected

$checkConnection = Get-PsSession | Where-Object ConfigurationName -eq "Microsoft.Exchange" -ErrorAction SilentlyContinue
if($checkConnection -eq $null){
    $cred=Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
    Import-PSSession $Session
}


#Functions for making the changes
function writeLog(){
    param(
        [String]$value1
    )
    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 | Out-File $logfile -Append
}
function addAddressAndSetDefault(){
    writeLog "***"
    writeLog "***Starting process for $mb"
    [String]$EmailAddresses = $mb.EmailAddresses
    [string]$EmailAddresses.Replace("SMTP","smtp")
    writelog "***Formatting new address for $mb"
    [String]$NewAddress = " SMTP:" + $mb.Alias + "@" + $DomainName
    writelog "***Writing new address to mailbox for $mb"
    Set-Mailbox -Identity $mb.alias -EmailAddresses @{add="$NewAddress"}
    writelog "***Process complete for $mb"
}

function addAddress(){
    writeLog "***"
    writeLog "***Starting process for $mb"
    [String]$EmailAddresses = $mb.EmailAddresses
    writelog "***Formatting new address for $mb"
    [String]$NewAddress = " smtp:" + $mb.Alias + "@" + $DomainName
    writelog "***Writing new address to mailbox for $mb"
    Set-Mailbox -Identity $mb.alias -EmailAddresses @{add="$NewAddress"}
    writelog "***Process complete for $mb"
}

#Logic
if($AllMailboxes -eq $True){
    $Mbs = Get-Mailbox
    write-host $mbs
    Foreach($Mb in $Mbs){ 
        if($IsDefault){
            addAddressAndSetDefault
        }else{
            addAddress
        }
    }
}elseif($Mailbox){
    $mb = $Mailbox
    if($IsDefault){
        addAddressAndSetDefault
    }else{
        addAddress
    }
}else{
    Write-Host "You must specify the -Mailbox or -AllMailboxes parameter" -ForegroundColor Red
}
