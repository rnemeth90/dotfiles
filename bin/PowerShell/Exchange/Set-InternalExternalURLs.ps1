####################################################################################################
# Set-InternalExternalURLs.ps1
#
# v04 May2011 by Ståle Hansen (http://msunified.net)
#
# Idea from MVP's Anderson Patricio and Pat Richard, script designed for Exchange 2010 prerequisites
# Thanks to Marjus Sirvinsks for adapting the script further
#
####################################################################################################
[System.Console]::ForegroundColor = [System.ConsoleColor]::White
clear-host

	write-host
	write-host Script for setting Internal and External URLs on Exchange 2007/2010
	write-host
	write-host Please choose one of the following:
	write-host
	write-host '1) Exchange 2010 Internal URLs'
	write-host '2) Exchange 2010 External URLs'
	write-host '3) Exchange 2007 Internal URLs'
	write-host '4) Exchange 2007 External URLs'
	write-host '5) Exchange 2003 Legacy URL'
	write-host '6) List Current URL Config'
	write-host '7) Cancel' -ForegroundColor Red
	write-host
	$opt = Read-Host "Select an option [1-7]"

switch ($opt)    {

1{
# Set internal URL on all Exchange 2010 Client Access Servers using input

Foreach($Server in Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -eq 14}){
$CASserver = $Server.Identity
$ADsite = Get-ExchangeServer $Server
$site = $ADsite.site

Write-Host
Write-Host "Found Exchange 2010 Client Access Server " -NoNewLine
Write-Host $CASserver -NoNewLine -Foregroundcolor Green
Write-Host " in ADsite " -NoNewLine
Write-Host $site -Foregroundcolor Green
Write-Host

}

$urlpath = Read-Host "Type internal FQDN for Exchange 2010 Client Access (without https://)"
Write-Host "Will set InternalUrl as " -NoNewLine
Write-Host "https://$urlpath/" -NoNewLine -foregroundcolor Green
Write-Host " on all Exchange 2010 Client Access Servers"

Write-Host
Write-Host "Press " -NoNewLine
Write-Host "Enter" -NoNewLine -foregroundcolor Green
Write-Host " to continue, or " -NoNewLine
Write-Host "CTR+C " -NoNewLine -foregroundcolor Red
Write-Host "to cancel"
[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray
Read-Host
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Foreach($Server in Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -eq 14}){
$CASserver = $Server.Identity

Get-AutodiscoverVirtualDirectory -Server $CASserver | Set-AutodiscoverVirtualDirectory –InternalUrl "https://$urlpath/Autodiscover/Autodiscover.xml"
Get-ClientAccessServer -Identity $CASserver | Set-ClientAccessServer –AutodiscoverServiceInternalUri "https://$urlpath/Autodiscover/Autodiscover.xml"
Get-WebservicesVirtualDirectory -Server $CASserver | Set-WebservicesVirtualDirectory –InternalUrl "https://$urlpath/Ews/Exchange.asmx"
Get-OabVirtualDirectory -Server $CASserver | Set-OabVirtualDirectory –InternalUrl "https://$urlpath/Oab"
Get-OwaVirtualDirectory -Server $CASserver | Set-OwaVirtualDirectory –InternalUrl "https://$urlpath/Owa"
Get-EcpVirtualDirectory -Server $CASserver | Set-EcpVirtualDirectory –InternalUrl "https://$urlpath/Ecp"
Get-ActiveSyncVirtualDirectory -Server $CASserver | Set-ActiveSyncVirtualDirectory -InternalUrl "https://$urlpath/Microsoft-Server-ActiveSync"
}

#Get commands to doublecheck the config
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Get-AutodiscoverVirtualDirectory | ft Identity,InternalUrl
Get-ClientAccessServer | ft Identity,AutodiscoverServiceInternalUri
Get-WebservicesVirtualDirectory | ft Identity,InternalUrl
Get-OabVirtualDirectory | ft Identity,InternalUrl
Get-OwaVirtualDirectory | ft Identity,InternalUrl
Get-EcpVirtualDirectory | ft Identity,InternalUrl
Get-ActiveSyncVirtualDirectory | ft Identity,InternalUrl

[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray

}

2{
# Set external URL on all Exchange 2010 Client Access Servers using input

Foreach($Server in Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -eq 14}){
$CASserver = $Server.Identity
$ADsite = Get-ExchangeServer $Server
$site = $ADsite.site

Write-Host
Write-Host "Found Exchange 2010 Client Access Server " -NoNewLine
Write-Host $CASserver -NoNewLine -Foregroundcolor Green
Write-Host " in ADsite " -NoNewLine
Write-Host $site -Foregroundcolor Green
Write-Host

}

$urlpath = Read-Host "Type external FQDN for Exchange 2010 Client Access (without https://)"
Write-Host "Will set ExternalUrl as " -NoNewLine
Write-Host "https://$urlpath/" -NoNewLine -foregroundcolor Green
Write-Host " on all Exchange 2010 Client Access Servers"

Write-Host
Write-Host "Press " -NoNewLine
Write-Host "Enter" -NoNewLine -foregroundcolor Green
Write-Host " to continue, or " -NoNewLine
Write-Host "CTR+C " -NoNewLine -foregroundcolor Red
Write-Host "to cancel"
[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray
Read-Host
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Foreach($Server in Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -eq 14}){
$CASserver = $Server.Identity

Get-AutodiscoverVirtualDirectory -Server $CASserver | Set-AutodiscoverVirtualDirectory –ExternalUrl "https://$urlpath/Autodiscover/Autodiscover.xml"
Get-webservicesVirtualDirectory -Identity $CASserver | Set-webservicesVirtualDirectory –ExternalUrl "https://$urlpath/Ews/Exchange.asmx"
Get-OabVirtualDirectory -Server $CASserver | Set-OabVirtualDirectory –ExternalUrl "https://$urlpath/Oab"
Get-OwaVirtualDirectory -Server $CASserver | Set-OwaVirtualDirectory –ExternalUrl "https://$urlpath/Owa"
Get-EcpVirtualDirectory -Server $CASserver | Set-EcpVirtualDirectory –ExternalUrl "https://$urlpath/Ecp"
Get-ActiveSyncVirtualDirectory -Server $CASserver | Set-ActiveSyncVirtualDirectory -ExternalUrl "https://$urlpath/Microsoft-Server-ActiveSync"
}

#Get commands to doublecheck the config
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Get-AutodiscoverVirtualDirectory | ft Identity,ExternalUrl
Get-webservicesVirtualDirectory | ft Identity,ExternalUrl
Get-OabVirtualDirectory | ft Identity,ExternalUrl
Get-OwaVirtualDirectory | ft Identity,ExternalUrl
Get-EcpVirtualDirectory | ft Identity,ExternalUrl
Get-ActiveSyncVirtualDirectory | ft Identity,ExternalUrl

[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray

}

3{
# Set Exchange 2007 Internal URLs using input

Foreach($Server in Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -lt 14}){
$CASserver = $Server.Identity
$ADsite = Get-ExchangeServer $Server
$site = $ADsite.site

Write-Host
Write-Host "Found Exchange 2007 Client Access Server " -NoNewLine
Write-Host $CASserver -NoNewLine -Foregroundcolor Green
Write-Host " in ADsite " -NoNewLine
Write-Host $site -Foregroundcolor Green
Write-Host

}

Write-Host "Type internal FQDN for Exchange 2007 Client Access"
Write-Host "Please type http:// or https:// in front: " -NoNewLine -foregroundcolor Yellow
$urlpath = Read-Host
Write-Host
Write-Host "Will set InternalUrl as " -NoNewLine
Write-Host "$urlpath/" -NoNewLine -foregroundcolor Green
Write-Host " on all Exchange 2007 Client Access Servers"

Write-Host
Write-Host "Press " -NoNewLine
Write-Host "Enter" -NoNewLine -foregroundcolor Green
Write-Host " to continue, or " -NoNewLine
Write-Host "CTR+C " -NoNewLine -foregroundcolor Red
Write-Host "to cancel"
[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray
Read-Host
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Foreach($Server in Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -lt 14}){
$CASserver = $Server.Identity

Get-AutodiscoverVirtualDirectory -Server $CASserver | Set-AutodiscoverVirtualDirectory –InternalUrl "$urlpath/Autodiscover/Autodiscover.xml"
Get-ClientAccessServer -Identity $CASserver | Set-ClientAccessServer –AutodiscoverServiceInternalUri "$urlpath/Autodiscover/Autodiscover.xml"
Get-WebservicesVirtualDirectory -Server $CASserver | Set-WebservicesVirtualDirectory –InternalUrl "$urlpath/Ews/Exchange.asmx"
Get-OabVirtualDirectory -Server $CASserver | Set-OabVirtualDirectory –InternalUrl "$urlpath/Oab"
Get-OwaVirtualDirectory -Identity "$CASserver\OWA (Default Web site)"  | Set-OwaVirtualDirectory –InternalUrl "$urlpath/Owa"
Get-ActiveSyncVirtualDirectory -Server $CASserver | Set-ActiveSyncVirtualDirectory -InternalUrl "$urlpath/Microsoft-Server-ActiveSync"
}

#Get commands to doublecheck the config
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Get-AutodiscoverVirtualDirectory | ft Identity,InternalUrl
Get-ClientAccessServer | ft Identity,AutodiscoverServiceInternalUri
Get-WebservicesVirtualDirectory | ft Identity,InternalUrl
Get-OabVirtualDirectory | ft Identity,InternalUrl
Get-OwaVirtualDirectory | ft Identity,InternalUrl
Get-ActiveSyncVirtualDirectory | ft Identity,InternalUrl

[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray

}

4{
# Set external URL on Exchange 2007 Client Access Servers using input

Foreach($Server in Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -lt 14}){
$CASserver = $Server.Identity
$ADsite = Get-ExchangeServer $Server
$site = $ADsite.site

Write-Host
Write-Host "Found Exchange 2007 Client Access Server " -NoNewLine
Write-Host $CASserver -NoNewLine -Foregroundcolor Green
Write-Host " in ADsite " -NoNewLine
Write-Host $site -Foregroundcolor Green
Write-Host
}

$urlpath = Read-Host "Type external FQDN for Client Access"
Write-Host "Will set ExternalUrl as " -NoNewLine
Write-Host "https://$urlpath/" -NoNewLine -foregroundcolor Green
Write-Host " on all Exchange 2007 Client Access Servers"

Write-Host
Write-Host "Press " -NoNewLine
Write-Host "Enter" -NoNewLine -foregroundcolor Green
Write-Host " to continue, or " -NoNewLine
Write-Host "CTR+C " -NoNewLine -foregroundcolor Red
Write-Host "to cancel"
[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray
Read-Host
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Foreach($Server in Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -lt 14}){
$CASserver = $Server.Identity

Get-AutodiscoverVirtualDirectory -Server $CASserver | Set-AutodiscoverVirtualDirectory –ExternalUrl "https://$urlpath/Autodiscover/Autodiscover.xml"
Get-webservicesVirtualDirectory -Server $CASserver | Set-webservicesVirtualDirectory –ExternalUrl "https://$urlpath/Ews/Exchange.asmx"
Get-OabVirtualDirectory -Server $CASserver | Set-OabVirtualDirectory –ExternalUrl "https://$urlpath/Oab"
Get-OwaVirtualDirectory -Identity "$CASserver\OWA (Default Web site)" | Set-OwaVirtualDirectory –ExternalUrl "https://$urlpath/Owa"
Get-ActiveSyncVirtualDirectory -Server $CASserver | Set-ActiveSyncVirtualDirectory -ExternalUrl "https://$urlpath/Microsoft-Server-ActiveSync"

}

#Get commands to doublecheck the config
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Get-AutodiscoverVirtualDirectory | ft Identity,ExternalUrl
Get-webservicesVirtualDirectory | ft Identity,ExternalUrl
Get-OabVirtualDirectory | ft Identity,ExternalUrl
Get-OwaVirtualDirectory | ft Identity,ExternalUrl
Get-ActiveSyncVirtualDirectory | ft Identity,ExternalUrl

[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray

}

5{
$legacy = Read-Host "For Legacy Exchange 2003 coexistence, type external FQDN"
Write-Host "Will use" -NoNewLine
Write-Host " https://$legacy/Exchange" -NoNewLine -foregroundcolor Green
Write-Host " as Exchange 2003 URL on all Exchange 2010 Client Access Servers"

Write-Host
Write-Host "Press " -NoNewLine
Write-Host "Enter" -NoNewLine -foregroundcolor Green
Write-Host " to continue, or " -NoNewLine
Write-Host "CTR+C " -NoNewLine -foregroundcolor Red
Write-Host "to cancel"
[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray
Read-Host
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Foreach($Server in Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -eq 14}){
$CASserver = $Server.Identity

Get-OwaVirtualDirectory -Server $CASserver | Set-OwaVirtualDirectory –Exchange2003Url "https://$legacy/Exchange"

}

#get command to doublecheck the config
[System.Console]::ForegroundColor = [System.ConsoleColor]::White

Get-OwaVirtualDirectory | ft Identity,Exchange2003Url

[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray

}

6{
# Display current Exchange Internal and External URL configuration
# Testing if Exchange 2010 servers present, if not dont display ECP else display with ECP

$Server = Get-ClientAccessServer | Get-ExchangeServer | where-object {$_.AdminDisplayVersion.Major -eq 14}
if ($server -eq $Null){

# No Exchange 2010 servers present

Get-AutodiscoverVirtualDirectory | fl Identity,InternalUrl,ExternalUrl
Get-ClientAccessServer | fl Identity,AutodiscoverServiceInternalUri
Get-WebservicesVirtualDirectory | fl Identity,InternalUrl,ExternalUrl
Get-OabVirtualDirectory | fl Identity,InternalUrl,ExternalUrl
Get-OwaVirtualDirectory | fl Identity,InternalUrl,ExternalUrl
Get-ActiveSyncVirtualDirectory | fl Identity,InternalUrl,ExternalUrl

[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray
}
else{

# Exchange 2010 servers present

Get-AutodiscoverVirtualDirectory | fl Identity,InternalUrl,ExternalUrl
Get-ClientAccessServer | fl Identity,AutodiscoverServiceInternalUri
Get-WebservicesVirtualDirectory | fl Identity,InternalUrl,ExternalUrl
Get-OabVirtualDirectory | fl Identity,InternalUrl,ExternalUrl
Get-OwaVirtualDirectory | fl Identity,InternalUrl,ExternalUrl,Exchange2003Url
Get-EcpVirtualDirectory | fl Identity,InternalUrl,ExternalUrl
Get-ActiveSyncVirtualDirectory | fl Identity,InternalUrl,ExternalUrl

[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray

}
}

7{

[System.Console]::ForegroundColor = [System.ConsoleColor]::Gray

}
		}
