<#
    .SYNOPSIS 
     Tests Migration Server Availability/Connectivity and Creates a Migration Endpoint if connection=successful.
    .EXAMPLE
     Create-MigrationEndpoint
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     This script will test the autodiscover availability of an Exchange server and create a migration endpoint if the 
     connection is successful. 
#>

$cred = Get-Credential
$EmailAddress = $cred.UserName
$PremCreds = Get-Credential

Clear-Host

Write-Host "Connecting to Office 365" -ForegroundColor Green
Connect-MsolService -Credential $cred

Write-Host "Connecting to Exchange Online" -ForegroundColor Green
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -AllowRedirection -Authentication Basic
Import-PSSession $session

Clear-Host
Write-Host "Testing Migration Server Availability" -ForegroundColor Green
$migServTest = Test-MigrationServerAvailability -ExchangeOutlookAnywhere -Autodiscover -EmailAddress $PremCreds.UserName -Credentials $PremCreds
#$migServTest.Result

if($migServTest.Result -eq "Failed"){
    Clear-Host
    Write-Host $migServTest.Message -ForegroundColor Red
    }
else{
    New-MigrationEndpoint -ExchangeOutlookAnywhere -Name "Production Migration Endpoint" -Autodiscover -EmailAddress $PremCreds.UserName -Credentials $PremCreds
    }