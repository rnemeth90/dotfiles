#
# Remove Proxyaddress - PowerShell Script Version 1.0
# Author - Santhosh Sivarajan
#

## TO DO:
# modify script to include distribution groups

$OUScope = "OU=My Users,DC=Sivarajan,DC=com"
$N = 0
Write-Host "Searching mailboxes in $OUScope...."
foreach($Tmailbox in Get-Mailbox -organizationalunit  $OUScope -ResultSize Unlimited) 
                {
                $Tmailbox.EmailAddresses | ?{$_.AddressString -like '*@test.com'} | %{
                Set-Mailbox $Tmailbox -EmailAddresses @{remove=$_}
                Write-host "Removing $_ from $Tmailbox Mailbox"
                $N++
                }
}
