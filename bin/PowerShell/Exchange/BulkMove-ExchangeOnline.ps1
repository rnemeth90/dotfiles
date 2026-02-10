<#
    .SYNOPSIS 
     Moves users specified in a CSV file. The CSV file must be named "users.csv" and exist within the same directory
     as the script. The column name in the CSV must be "UPN". 
    .PARAMETER Mode
     The script accepts one parameter that is mandatory. The
     parameter specifies whether the script runs in "test mode" or "real mode". Test mode does not actually make any 
     modifications. Real mode does. To use real mode, pass the value "real" to the "-mode" parameter. To use test mode, 
     pass "test" to the "-mode" parameter.
    .EXAMPLE
     BulkMove-ExchangeOnline -Mode Test
    .EXAMPLE
     BulkMove-ExchangeOnline -Mode Real
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

param(
    [Parameter(Mandatory=$True)]
    [String]$PathToCsv,
    [Parameter(Mandatory=$True)]
    [String]$TargetDomain,
    [Parameter(Mandatory=$True)]
    [String]$HybridAddress
)
$users = Import-Csv $PathToCsv
$365Creds = Get-Credential
$OnPremCreds = Get-Credential
#$targetDomain = "ecipay.mail.onmicrosoft.com"
#$hybridAddress = "webmail.ecipay.com"
#$ErrorActionPreference="SilentlyContinue"
#$ErrorActionPreference = "Continue"

Start-Transcript -path %temp%\BulkMove-ExchangeOnline_Results.log -append

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $365Creds -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $365Creds

foreach($user in $users){
    try {
        New-MoveRequest -Identity $user.alias -Remote -RemoteHostName $HybridAddress -TargetDeliveryDomain $TargetDomain -RemoteCredential $OnPremCreds -BadItemLimit 1000
    }
    catch {
        Write-Host "Unable to migrate user:" $user.alias "- Please try again." -ForegroundColor Red
    }
} 

Get-PSSession | Remove-PSSession

Stop-Transcript | out-null
