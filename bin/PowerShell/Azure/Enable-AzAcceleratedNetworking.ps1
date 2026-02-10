Login-AzureRmAccount

$nic = Get-AzureRmNetworkInterface -ResourceGroupName “YourResourceGroupName” -Name “YourNicName”

$nic.EnableAcceleratedNetworking = $true

$nic | Set-AzureRmNetworkInterface