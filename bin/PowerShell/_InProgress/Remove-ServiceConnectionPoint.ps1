<#
    .SYNOPSIS 
     Removes the Service Connection Point in Active Directory for Microsoft Exchange 
    .EXAMPLE
     Remove-ServiceConnectionPoint
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .Version
     1.1
#>


$autodiscoverVD = Get-AutodiscoverVirtualDirectory | fl name, server, internalurl, identity

if($autodiscoverVD.internalUrl -ne $null){
    try{
        Remove-AutodiscoverVirtualDirectory $autodiscoverVD.identity 
    }
    catch{
        Write-Host "Unable to remove SCP from Active Directory"
    }
}
else{
    Write-Host "SCP is already null"
}
