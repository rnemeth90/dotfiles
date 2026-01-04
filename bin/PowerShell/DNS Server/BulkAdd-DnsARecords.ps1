<#
.SYNOPSIS
BulkAdd-DnsARecords.ps1 - Add A records to a Windows DNS server en mass

.DESCRIPTION 
This script will obtain DNS A record values from a csv file and create records
within a Windows DNS server zone. This script will work with AD zones or zone files.

.OUTPUTS
Results are output to a text log file.

.PARAMETER File
The .csv file containing DNS resouce record values. The csv should have two columns. The first
column header should have a value of "name" and the second column header should have a value of "ip".

.PARAMETER Zone
The zone that you would like to create the records in

.PARAMETER Log
A boolean value specifying whether or not you would like to log changes to a text file

.EXAMPLE
.\BulkAdd-DnsARecords.ps1 -File addTheseRecords.csv -Zone ad.contoso.com -log:$true

.NOTES
Written by: Ryan Nemeth

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

Change Log
V1.00, 12/15/2017 - Initial version
#>

#The .csv file containing DNS resouce record values
param(
    [Parameter(Mandatory=$true)]
    [string]$File,
    #The zone that you would like to create the records in
    [Parameter(Mandatory=$true)]
    [string]$Zone
    #A boolean value specifying whether or not you would like to log changes to a text file
    #[Parameter(Mandatory=$false)]
    #[string]$log
)


$records = Import-Csv -Path $File
$logfile = ".\BulkAdd-DnsARecords.log"

function Write-Log(){
    param(
        [String]$value1,
        [String]$value2,
        [String]$value3,
        [String]$value4
    )
    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 + $value2 + $value3 + $value4 | Out-File $logfile -Append
}

#Check if DNSServer PS Module exists
if (!(Get-Module -Name DNSServer)) {
    Write-Host "Cannot find DNSServer PS Module. Is it installed?" -ForegroundColor Red
}

#Create the A records
foreach ($record in $records) {
    Write-Log "'Adding ' + $record.name +':'+$record.ip ' to zone ' $Zone" 
    Write-Host "Adding " + $record.name +":"+$record.ip " to zone " $Zone 
    Add-DnsServerResourceRecordA -Name $record.name -ZoneName $Zone -AllowUpdateAny -IPv4Address $record.ip -TimeToLive 01:00:00
    #throw "Unable to create record with value " +$record.name+":"+$record.ip
}


