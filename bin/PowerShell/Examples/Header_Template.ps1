<#
    .SYNOPSIS 
     Removes users specified in a CSV file. The CSV file must be named "users.csv" and exist within the same directory
     as the script. The column name in the CSV must be "UPN". 
    .PARAMETER Mode
     The script accepts one parameter that is mandatory. The
     parameter specifies whether the script runs in "test mode" or "real mode". Test mode does not actually make any 
     modifications. Real mode does. To use real mode, pass the value "real" to the "-mode" parameter. To use test mode, 
     pass "test" to the "-mode" parameter.
    .EXAMPLE
     BulkRemove-Office365Accounts -Mode Test
    .EXAMPLE
     BulkRemove-Office365Accounts -Mode Real
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
    .EXAMPLE
     BulkRemove-Office365Accounts.ps1 [-Mode <String>]
#>

#---------------------------------------------------------------------------------------------------------------------------


<#
.SYNOPSIS
Add-SMTPAddresses.ps1 - Add SMTP addresses to Office 365 users for a new domain name

.DESCRIPTION 
This PowerShell script will add new SMTP addresses to existing Office 365 mailbox users
for a new domain. This script fills the need to make bulk email address changes
in Exchange Online when Email Address Policies are not available.

.OUTPUTS
Results are output to a text log file.

.PARAMETER Domain
The new domain name to add SMTP addresses to each Office 365 mailbox user.

.PARAMETER MakePrimary
Specifies that the new email address should be made the primary SMTP address for the mailbox user.

.PARAMETER Commit
Specifies that the changes should be committed to the mailboxes. Without this switch no changes
will be made to mailboxes but the changes that would be made are written to a log file for evaluation.

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

Change Log
V1.00, 21/05/2015 - Initial version
#>
