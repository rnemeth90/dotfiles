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

$servers = get-content .\servers.txt
$credentials = Get-Credential
$password = ""


foreach($server in $servers){
    Connect-ViServer -Server $server -Credential $credentials
    Write-Host "Setting password for $server"
    $account = Get-VMHostAccount -Server $server -User "root"
    $account | Set-VMHostAccount –Password $password
}
    