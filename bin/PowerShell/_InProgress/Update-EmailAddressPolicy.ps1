Get-EmailAddressPolicy | where {$_.RecipientFilterType -eq "Legacy"} | Set-EmailAddressPolicy -IncludedRecipients AllRecipients
Update-EmailAddressPolicy