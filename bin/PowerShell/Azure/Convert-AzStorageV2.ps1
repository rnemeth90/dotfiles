<#
.SYNOPSIS
Convert-AzStorageV2.ps1 - Convert all storage accounts in a subscription to v2

.DESCRIPTION 
This PowerShell script will convert all v1 storage accounts found in a subscription to v2. 

.OUTPUTS
Results are output to a text log file and console.

.NOTES
Written by: Ryan Nemeth

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

Change Log:
V1.00, 09/13/2019 - Initial version
#>

#Function for writing to log file
$logfile = ".\Convert-AzStorageV2.log"
function writeLog(){
    param(
        [String]$value1,
        [String]$value2,
        [String]$value3,
        [String]$value4
    )

    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 + $value2 + $value3 + $value4 | Out-File $logfile -Append
}

writeLog "Gathering storage accounts..."
$storageAccounts = Get-AzStorageAccount

foreach ($acct in $storageAccounts) {
    if ($acct.kind -eq "Storage") {
        Set-AzStorageAccount -ResourceGroupName $acct.ResourceGroupName -AccountName $acct.StorageAccountName -UpgradeToStorageV2 | Out-Null
        Write-Host "Upgrading $acct.StorageAccountName to v2"
    }
}

