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

$users = get-content .\usersToMigrate.txt
$sourceDC = "Enter Source Domain Controller Here"
$DestinationDC = "Enter Destination Domain Controller Here"
$sourceCreds = Get-Credential 
$destinationCreds = Get-Credential
$targetOu = "Enter Target OU in Destination Domain Here"
$ErrorActionPreference="SilentlyContinue"
$ErrorActionPreference = "Continue"

Stop-Transcript | out-null
Start-Transcript -path .\results.txt -append
Stop-Transcript

foreach($user in $users){
    .\Prepare-MoveRequest.Ps1 -Identity $user -RemoteForestDomainController $sourceDC -RemoteForestCredential $sourceCreds `
    -LocalForestDomainController $DestinationDC -LocalForestCredential $destinationCreds -TargetMailUserOU $targetOu
}