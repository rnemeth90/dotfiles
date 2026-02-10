$creds = Get-Credential
$

foreach ($computername in $computerlist) {
    $result =  get-wmiobject win32_pingstatus -filter "address='$computername'"
    if ($result.statuscode -eq 0) {
        $remoteNic = get-wmiobject -class win32_networkadapter -computer $computername | where-object {$_.netconnectionID -eq "vNetwork"}
        $index = $remotenic.index
        $DNSlist = $(get-wmiobject win32_networkadapterconfiguration -computer $computername -Filter �IPEnabled=true� | where-object {$_.index -eq $index}).dnsserversearchorder
        $priDNS = $DNSlist | select-object -first 1
        Write-host "Changing DNS IP's on $computername" -b "Yellow" -foregroundcolor "black"
        $change = get-wmiobject win32_networkadapterconfiguration -computer $computername | where-object {$_.index -eq $index}
        $change.SetDNSServerSearchOrder($DNSservers) | out-null
        $changes = $(get-wmiobject win32_networkadapterconfiguration -computer $computername -Filter �IPEnabled=true� | where-object {$_.index -eq $index}).dnsserversearchorder
        Write-host "$computername's Nic1 Dns IPs $changes"
    }
    else {
        Write-host "$Computername is down cannot change IP address" -b "Red" -foregroundcolor "white"
    }
}
