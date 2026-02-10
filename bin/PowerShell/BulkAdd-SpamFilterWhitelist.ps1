<#
.SYNOPSIS
BulkAdd-SpamFilterPolicies - Whitelist New Domains in an Exchange Online Spam Filter

.DESCRIPTION 
This script will add new domains to the whitelist in the specified spam filter policy.
This script will only work with Exchange Online. 

.OUTPUTS
Results are output to a text log file named identical to the script.

.PARAMETER SpamFilter
The name of the Exchange Online Spam Filter policy that you would like to configure. 

.PARAMETER FilePath
The path to a text file containing a list of domains to add to the whitelist.

.PARAMETER Commit
This parameter specifies that you want to commit the changes to Exchange Online. Not 
specifying this parameter will not make any changes. However, it will output the changes
that would be made to the console and a log file. 

.EXAMPLE
BulkAdd-SpamFilterWhitelist.ps1 -SpamFilter default -FilePath .\domainsToAdd.txt

.EXAMPLE
BulkAdd-SpamFilterWhitelist.ps1 -SpamFilter default -FilePath .\domainsToAdd.txt -Commit $True

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

param(
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [String]$SpamFilter,
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [String]$FilePath,
    # Parameter help description
    [Parameter(Mandatory=$false)]
    [bool]$Commit
)

###########
#Variables#
###########

$scriptName = "BulkAdd-SpamFilterWhitelist"
$currentWhiteList = $null
$logfile = $scriptName+".log"

###########
#Functions#
###########

#Function for creating a log file
function writeLog(){
    param(
        [String]$value1
    )
    $date = Get-Date -DisplayHint DateTime
    [String]$date + " ***" + $value1 | Out-File $logfile -Append
}

#Connect to Exchange Online if not already connected
function checkConnection(){
    $checkConn = Get-PSSession
    if($checkConn.ComputerName -ne "ps.outlook.com"){
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential (Get-Credential) -Authentication Basic -AllowRedirection
    Import-PSSession $session
    }
}

checkConnection

########
#Script#
########

#Get current white list for spam filter and write to log
$currentWhiteList = Get-HostedContentFilterPolicy -Identity $SpamFilter 
$currentDomains = @($currentWhiteList | Select-Object -Expandproperty AllowedSenderDomains)
writeLog "Current White List:"
writelog $currentWhiteList.allowedsenderdomains
Write-Host "Current White List:" $currentWhiteList.allowedsenderdomains

#Get additions and form new whitelist
$newDomains = Get-Content $FilePath
$newWhiteList = $currentDomains + $newDomains
writeLog "New White List:"
writelog $newWhiteList
Write-Host "New White List:" $newWhiteList

#write whitelist if parameter is specified
if($Commit){
    foreach($domain in $newDomains){
        Write-Host "Adding" $domain "to" $SpamFilter "spam filter policy!"
        #writeLog "Adding" $domain "to" $SpamFilter "spam filter policy!"
        Set-HostedContentFilterPolicy -Identity $SpamFilter -AllowedSenderDomains @{Add="$domain"}
    }
    writelog "Committing Changes!"
}
else{
    writeLog "Changes not committed, re-run the script with the -Commit switch when you're ready to apply the changes."
    Write-Warning "No changes made due to -Commit switch not being specified."
}



