

Param(
   [Parameter(Mandatory=$True)]
   [String]$ZoneName,
   [Parameter(Mandatory=$True)]
   [string]$csvFile
)

$records = Import-Csv $csvFile

Add-DnsServerPrimaryZone -Name $ZoneName -ReplicationScope "Forest" -Passthru


foreach ($record in $records) {
    If($record.type = 'a'){
        Add-DnsServerResourceRecordA -Name $record.name -zonename $zonename -ipv4address $record.data -TimeToLive 01:00:00
    }
    elseif($record.type='cname'){
        Add-DnsServerResourceRecordCName -Name $record.name -HostNameAlias $record.data -ZoneName $zoneName
    }
}