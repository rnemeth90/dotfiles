$oldServer = read-host "Exchange 2007 Server Name"
$newServer = Read-Host "Exchange 2013 Server Name"

$ex2013OWA = get-OwaVirtualDirectory –Identity “$newServer\owa (Default Web Site)” 
Write-Host = "Exchange 2013 OWA" $ex2013OWA
$ex2007OWA = get-OwaVirtualDirectory –Identity “$oldServer\owa (Default Web Site)”
Write-Host = "Exchange 2007 OWA" $ex2007OWA


$ex2013AS = get-activesyncvirtualdirectory –Identity  “$newServer\Microsoft-Server-ActiveSync (Default Web Site)”
Write-Host = "Exchange 2013 OWA" $ex2013AS
$ex2007AS = get-activesyncvirtualdirectory –Identity “$oldServer\Microsoft-Server-ActiveSync (Default Web Site)”
Write-Host = "Exchange 2007 OWA" $ex2007AS


$ex2013OA = get-OutlookAnywhere –Identity   “$newServer\Rpc (Default Web Site)”
Write-Host = "Exchange 2013 OA" $ex2013OA
$ex2007OA = get-OutlookAnywhere –Identity “$oldServer\Rpc (Default Web Site)”
Write-Host = "Exchange 2007 OA" $ex2007OA


$ex2013ews = get-WebServicesVirtualDirectory –Identity    “$newServer\EWS (Default Web Site)”
Write-Host = "Exchange 2013 EWS" $ex2013ews
$ex2007ews = get-WebServicesVirtualDirectory –Identity  “$oldServer\EWS (Default Web Site)”
Write-Host = "Exchange 2007 EWS" $ex2007ews

$ex2013AD = get-clientaccessserver -identity $newServer | select AutoDiscoverServiceInternalUri
Write-Host "Exchange 2013 AD:" $ex2013ad
$ex2007AD = get-clientaccessserver -identity $oldServer | select AutoDiscoverServiceInternalUri
Write-Host "Exchange 2007 AD:" $ex2007ad

$ex2013ECP = get-EcpVirtualDirectory –Identity “$newServer\ecp (Default Web Site)”
Write-Host "Exchange 2013 ECP:" $ex2013ECP