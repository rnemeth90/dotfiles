# Dynamically pulling the DHCP servers in a Active Directory domain
$DHCP_Servers = Get-DhcpServerInDC | Sort-Object -Property DnsName
$Output = Foreach ($DHCP_Server in $DHCP_Servers) {
    # Going through the DHCP servers that were returned one at a time to pull statistics
    try {
        $DHCP_Scopes = Get-DhcpServerv4Scope –ComputerName $DHCP_Server.DNSName -ErrorAction Stop
    } catch {
        Write-Warning "Couldn't reach server $($DHCP_Server.DNSName)"
        $DHCP_Scopes = $Null
    }
    Foreach ($DHCP_Scope in $DHCP_Scopes) {
        # Going through the scopes returned in a given server
        $DHCP_Scope_Stats = Get-DhcpServerv4ScopeStatistics -ComputerName $DHCP_Server.DNSName -ScopeId $DHCP_Scope.ScopeId
        [PSCustomObject] @{
            'DHCP Server'    = $DHCP_Server.DNSName
            'DHCP IP'        = $DHCP_Server.IPAddress
            'Scope ID'       = $DHCP_Scope.ScopeId.IPAddressToString
            'Scope Name'     = $DHCP_Scope.Name
            'Scope State'    = $DHCP_Scope.State
            'In Use'         = $DHCP_Scope_Stats.InUse
            'Free'           = $DHCP_Scope_Stats.Free
            '% In Use'       = ([math]::Round($DHCP_Scope_Stats.PercentageInUse, 0))
            'Reserved'       = $DHCP_Scope_Stats.Reserved
            'Subnet Mask'    = $DHCP_Scope.SubnetMask
            'Start Range'    = $DHCP_Scope.StartRange
            'End Range'      = $DHCP_Scope.EndRange
            'Lease Duration' = $DHCP_Scope.LeaseDuration
        }
    }
}


New-HTML {
    New-HTMLTab -Name 'Summary' {
        New-HTMLSection -HeaderText 'All servers' {
            New-HTMLTable -DataTable $DHCP_Servers
        }
        foreach ($Server in $DHCP_Servers) {
            New-HTMLSection -Invisible {
                try {
                    $Database = Get-DhcpServerDatabase -ComputerName $Server.DnsName
                } catch {
                    continue
                }
                New-HTMLSection -HeaderText "Server $($Server.DnsName) - Database Information" {
                    New-HTMLTable -DataTable $Database
                }

                try {
                    $AuditLog = Get-DhcpServerAuditLog -ComputerName $Server.DnsName
                } catch {
                    continue
                }
                New-HTMLSection -HeaderText "Server $($Server.DnsName) - Audit Log" {
                    New-HTMLTable -DataTable $AuditLog
                }
            }
        }
    }
    New-HTMLTab -Name 'All DHCP Scopes' {
        New-HTMLSection -HeaderText 'DHCP Report' {
            New-HTMLTable -DataTable $Output {
                New-TableCondition -Name '% In Use' -Operator ge -Value 95 -BackgroundColor Red -Color White -Inline -ComparisonType number
                New-TableCondition -Name '% In Use' -Operator ge -Value 80 -BackgroundColor Yellow -Color Black -Inline -ComparisonType number
                New-TableCondition -Name '% In Use' -Operator lt -Value 80 -BackgroundColor Green -Color White -Inline -ComparisonType number
                New-TableCondition -Name 'Scope State' -Operator eq -Value 'Inactive' -BackgroundColor Gray -Color White -Inline -ComparisonType string
                New-TableHeader -Title "DHCP Scope Statistics Report ($(Get-Date))" -Alignment center -BackgroundColor BuddhaGold -Color White -FontWeight bold
                New-TableHeader -Names 'DHCP Server', 'DHCP IP' -Title 'Server Information' -Color White -Alignment center -BackgroundColor Gray
                New-TableHeader -Names 'Subnet Mask', 'Start Range', 'End Range', 'Lease Duration' -Title 'Scope Configuration' -Color White -Alignment center -BackgroundColor Gray

            }
        }
    }
} -FilePath $Env:UserProfile\Desktop\DHCPReport.html -Online -ShowHTML