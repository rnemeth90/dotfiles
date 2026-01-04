function Start-NetworkWatcherPacketCaptureForVmss {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VirtualMachineScaleSetName,
        [Parameter(Mandatory = $false)]
        [string]$vmssResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string]$NetworkWatcherLocation,
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        [Parameter(Mandatory = $false)]
        [string]$RemoteIPAddress = "1.1.1.1-255.255.255.255",
        [Parameter(Mandatory = $false)]
        [string]$LocalIPAddress = "1.1.1.1-255.255.255.255",
        [Parameter(Mandatory = $false)]
        [string]$RemotePort = "1-65535",
        [Parameter(Mandatory = $false)]
        [string]$LocalPort = "1-65535",
        [Parameter(Mandatory = $false)]
        [string]$Protocol = "ANY",
        [Parameter(Mandatory = $false)]
        [string]$TimeLimitInSeconds = "60"
    )

    $filter1 = New-AzPacketCaptureFilterConfig -Protocol $Protocol -RemoteIPAddress $RemoteIPAddress -LocalIPAddress $LocalIPAddress -LocalPort $LocalPort -RemotePort $RemotePort

    Write-Verbose "Gathering VMSS instances..."
    $vmss = Get-AzResource -Name $VirtualMachineScaleSetName
    $vmssId = $vmss.ResourceId

    if ([string]::IsNullOrEmpty($vmssResourceGroupName)) {
        $vmssResourceGroupName = $vmss.ResourceGroupName
    }

    Write-Verbose "Gathering VMSS resource Id..."
    $instances = (Get-AzVmssVm -ResourceGroupName $vmssResourceGroupName -VmScaleSetName $VirtualMachineScaleSetName)

    Write-Verbose "Finding Network Watcher instance in $($NetworkWatcherLocation)..."
    $networkWatcher = Get-AzNetworkWatcher | Where { $_.Location -eq $NetworkWatcherLocation }

    Write-Verbose "Searching for storage account $($StorageAccountName)..."
    $storageAccount = Get-AzResource -Name $StorageAccountName

    foreach ($instance in $instances) {

        $idString = "$($vmssId)/virtualMachines/$($instance.InstanceID)"

        Write-Verbose "Creating packet capture for VMSS instance $($instance.InstanceID)"
        New-AzNetworkWatcherPacketCapture `
            -NetworkWatcher $networkWatcher `
            -TargetVirtualMachineId $idString `
            -PacketCaptureName "$($instance.Name)" `
            -StorageAccountId $storageAccount.id `
            -TimeLimitInSeconds $TimeLimitInSeconds `
            -Filter $filter1 `
            -AsJob | Out-Null

        Write-Host "[CAPTURING] $($instance.Name)"
    }
}
