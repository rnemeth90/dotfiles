<#
    .SYNOPSIS 
     Deletes all IIS log files and emails a report once complete 
    .PARAMETER Mode
     
    .EXAMPLE
     
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>

################################
#        IIS Variables         #
################################

#Location of the IIS Log Files. Change it if you installed IIS to a different directory. 
$logLocation = ""
$deleteOlderThan = ""


################################
#  Mail Report Setup Variables #
################################

#Set to $false if you do not want to receive email alerts
$sendReport = $true

# From: address for email notifications (it doesn't have to be a real email address). Example: "WSUS@domain.com"
[string]$sender = "WSUS@ECIPAY.COM"

# To: address for email notifications. Example: "firstname.lastname@domain.com"
[string]$recipient = "rnemeth@ecipay.com"

# Subject: of the results email
[string]$mailSubject = "IIS Log Cleanup Results"

# Enter your SMTP server name. Example: "mailserver.domain.local" or "mail.domain.com" or "smtp.gmail.com"
[string]$smtpServer = "webmail.ecipay.com"

# Enter your SMTP port number. Example: "25" or "465" (Usually for SSL) or "587" or "1025"
[int32]$smtpPort = "25"

# Do you want to enable SSL communication for your SMTP Server
[boolean]$smtpSSLEnabled = $False

# Do you need to authenticate to the server? If not, leave blank.
[string]$smtpUsername = ""
[string]$smtpPassword = ""

################################
#       Remove IIS Files       #
################################

#get size of drive before cleaning
$freeBeforeClean = Get-PSDrive C | Select-Object Free

#clean the files
$files = Get-ChildItem -Path $logLocation -Recurse | Foreach-object ($_) {remove-item $_.fullname}
 
#get size of drive after cleaning
$freeAfterClean = Get-PSDrive C | Select-Object Free

################################
#     Create the Report        #
################################



################################
#       Mail the Report        #
################################

function MailReport {
    param (
        [ValidateSet("HTML")] 
        [String] $MessageContentType = "HTML"
    )
    $message = New-Object System.Net.Mail.MailMessage
    $mailer = New-Object System.Net.Mail.SmtpClient ($MailReportSMTPServer, $MailReportSMTPPort)
    $mailer.EnableSSL = $smtpSSLEnabled
    if ($smtpUsername -ne "") {
        $mailer.Credentials = New-Object System.Net.NetworkCredential($smtpUsername, $smtpPassword)
    }
    $message.From = $sender
    $message.To.Add($recipient)
    $message.Subject = $mailSubject
    $message.Body = $BodyHTML
    $message.IsBodyHtml = if ($MessageContentType -eq "HTML") { $True } else { $False }
    $mailer.send(($message))
}

################################
#      Clean Up Variables      #
################################

Get-Variable | Where-Object { $_.Name -match "" } | Remove-Variable

################################
#         End Of Code          #
################################


################################
# For Future Additions to Code #
################################

#******** TO BE DONE:
# Report Creation
# Logic for deleting files older than 'x' days