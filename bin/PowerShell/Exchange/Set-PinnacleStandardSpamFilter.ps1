<#
    .SYNOPSIS 
     Change the SPAM filter settings for Office 365 to Pinnacle standards
    .EXAMPLE
     Set-PinnacleStandardSpamFilter
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>

cls

try{
    $cred = Get-Credential
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection -ErrorAction SilentlyContinue -ErrorVariable $Error
    Import-PSSession $session
}
catch{
    Write-host $Error -ForegroundColor Red
}

cls

try{
    Enable-OrganizationCustomization -ErrorAction SilentlyContinue

    New-HostedContentFilterPolicy -Name "PinnacleStandardSpamPolicy"
    Set-HostedContentFilterPolicy -Identity "PinnacleStandardSpamPolicy" -EnableEndUserSpamNotifications $True -MakeDefault -EndUserSpamNotificationCustomFromAddress "Support@pinnacleofindiana.com" `
    -EndUserSpamNotificationCustomFromName "Pinnacle InfoSec Team" -HighConfidenceSpamAction Quarantine -SpamAction Quarantine -ErrorAction $Error

}
catch{
    Write-Host $Error -ForegroundColor Red
}


Remove-PSSession $session