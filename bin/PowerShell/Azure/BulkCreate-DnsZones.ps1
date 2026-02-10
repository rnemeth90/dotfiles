
$dnsZones = @("3shealth.ca",
"cfactor.ca",
"cfactor.cc",
"cfactor.net",
"cfactorworks.ca",
"cfactorworks.com",
"ciphimember.ca",
"cronuscorp.com",
"cronustech.com",
"cronustechnologies.com",
"enroll-smart.com",
"mygatewayonline.ca",
"mygatewayonline.com",
"mygatewayonline.info",
"powergridess.com",
"saho.org",
"shawcentral.ca",
"shawcentral.com",
"stpaulslutheran.ca",
"threelakesfiredepartment.ca")


$resourceGroup = "prod-rg-us-nc-dns-03"

Set-AzureRmContext -subscriptionId 72787baf-bb18-45db-8190-887f9d6b6894

foreach ($zone in $dnsZones) {
    New-AzureRmDnsZone -Name $zone -ResourceGroupName $resourceGroup -Tag @{ createdBy="ryanadmin"; env="prod"; applicationType="dns" }
}



$dnsZones = @("3shealth.ca",
"cfactor.ca",
"cfactor.cc",
"cfactor.net",
"cfactorworks.ca",
"cfactorworks.com",
"ciphimember.ca",
"cronuscorp.com",
"cronustech.com",
"cronustechnologies.com",
"enroll-smart.com",
"mygatewayonline.ca",
"mygatewayonline.com",
"mygatewayonline.info",
"powergridess.com",
"saho.org",
"shawcentral.ca",
"shawcentral.com",
"stpaulslutheran.ca",
"threelakesfiredepartment.ca")

foreach ($zone in $dnsZones) {
    az network dns zone import -g prod-rg-us-nc-dns-03 -n $zone -f .\$zone.zonefile.txt
}

