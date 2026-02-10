$recordSets = @(
    "sauce.vibehcm.com",
    "sauce-dev-epi.vibehcm.com",
    "www.sauce-dev-epi.vibehcm.com",
    "sauce-dev-fncb.vibehcm.com",
    "www.sauce-dev-fncb.vibehcm.com",
    "sauce-dev-indulge.vibehcm.com",
    "www.sauce-dev-indulge.vibehcm.com",
    "sauce-dev-iru.vibehcm.com",
    "sauce-dev-iru-qa.vibehcm.com",
    "sauce-dev-nh.vibehcm.com",
    "sauce-dev-nh-e2e.vibehcm.com",
    "sauce-dev-nh-qa.vibehcm.com",
    "sauce-dev-pwa.vibehcm.com",
    "www.sauce-dev-pwa.vibehcm.com",
    "sauce-dev-s.vibehcm.com",
    "sauce-dev-s-qa.vibehcm.com",
    "sauce-qa-pwa.vibehcm.com",
    "www.sauce-qa-pwa.vibehcm.com",
    "sauce-qa2-pwa.vibehcm.com",
    "sauce-verify-pwa-rcx.vibehcm.com",
    "www.sauce-verify-pwa-rcx.vibehcm.com"
)
$ip = "52.240.158.86"
$resourceGroup = "prod-rg-us-nc-dns-03"


foreach ($record in $recordSets) {
    $zone = ($record.Split(".")[-2,-1] -join ".")
    $rs = Get-AzDnsRecordSet -name ($record.Split(".")[0]) -RecordType A -ZoneName $zone -ResourceGroupName $resourceGroup
    $rs.Records[0].Ipv4Address = $ip
    Set-AzDnsRecordSet -RecordSet $rs
}