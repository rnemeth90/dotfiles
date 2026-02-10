<#
    .SYNOPSIS 
      Transfers features from one server to another, does not transfer configurations
    .EXAMPLE
     Transfer-WindowsFeature -Source <ServerName>
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     This function will get a list of installed features on a specified source server and then install
     those features on the server where the script is running. 
#>

Clear-Host

$domainList = array(Read-Host "List of domains (comma seperated) ")

foreach($domain in $domainList){
    $resolveList = Resolve-DnsName $domain -Type MX
    Write-Host $resolveList.Name $resolveList.type $resolveList.Exchange $resolveList.TTL

}
    