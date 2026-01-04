
Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File -FilePath username@domain.net.securestring
New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "username@myisp.net",(Get-Content -Path username@myisp.net.securestring | ConvertTo-SecureString)
Send-MailMessage -From "username@myisp.net" -To "robin@rcmtech.co.uk" -Subject "Something interesting just happened" -Body "Here's the details about the interesting thing" -SmtpServer smtp.myisp.net -Port 587 -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "username@myisp.net",(Get-Content -Path username@myisp.net.securestring | ConvertTo-SecureString))

$EmailTo = "myself@gmail.com"
$EmailFrom = "me@mydomain.com"
$Subject = "Test" 
$Body = "Test Body" 
$SMTPServer = "smtp.gmail.com" 
$filenameAndPath = "C:\CDF.pdf"
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
$SMTPMessage.Attachments.Add($attachment)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("username", "password"); 
$SMTPClient.Send($SMTPMessage)