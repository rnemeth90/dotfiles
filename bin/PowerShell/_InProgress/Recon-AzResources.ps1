# Windows Azure ARM Subscription Reconnaissance Script
# (C) 2018 Matt Burrough
# v1.0

# Requires the Azure PowerShell cmdlets be installed.
# See https://github.com/Azure/azure-powershell/ for details.

# Before running the script:
#   * Run: Import-Module Azure
#   * Authenticate to Azure in PowerShell
#   * You may also need to run: Set-ExecutionPolicy -Scope Process Unrestricted

# Show details of the current Azure subscription
Write-Output (" Subscription ","==============")
Write-Output ("Get-AzContext")
$context = Get-AzContext
$context
$context.Account
$context.Tenant
$context.Subscription

#Write-Output ("Get-AzRoleAssignment")
#Get-AzRoleAssignment

Write-Output ("", " Resources ","===========")
# Show the subscription's resource groups and a list of all of its resources
Write-Output ("Get-AzResourceGroup")
Get-AzResourceGroup | Format-Table ResourceGroupName,Location,ProvisioningState
Write-Output ("Get-AzResource")
Get-AzResource | Format-Table Name,ResourceType,ResourceGroupName

# Display Web Apps
Write-Output ("", " Web Apps ","==========")
Write-Output ("Get-AzWebApp")
Get-AzWebApp

# List Virtual Machines
Write-Output ("", " VMs ","=====")
$vms = Get-AzVM
Write-Output ("Get-AzVM")
$vms
foreach ($vm in $vms)
{
    Write-Output ("Get-AzVM -ResourceGroupName " + $vm.ResourceGroupName + "-Name " + $vm.Name)
    Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name
    Write-Output ("HardwareProfile:")
    $vm.HardwareProfile
    Write-Output ("OSProfile:")
    $vm.OSProfile
    Write-Output ("ImageReference:")
    $vm.StorageProfile.ImageReference
}

# Show Azure Storage
Write-Output ("", " Storage ","=========")
$SAs = Get-AzStorageAccount
Write-Output ("Get-AzStorageAccount")
$SAs
foreach ($sa in $SAs)
{
    Write-Output ("Get-AzStorageAccountKey -ResourceGroupName " + $sa.ResourceGroupName + " -StorageAccountName" + $sa.StorageAccountName)
    Get-AzStorageAccountKey -ResourceGroupName $sa.ResourceGroupName -StorageAccountName $sa.StorageAccountName
}

# Get Networking Settings
Write-Output ("", " Networking ","============")
Write-Output ("Get-AzNetworkInterface")
Get-AzNetworkInterface
Write-Output ("Get-AzPublicIpAddress")
Get-AzPublicIpAddress

# NSGs
Write-Output ("", " NSGs ","======")
foreach ($vm in $vms)
{
    $ni = Get-AzNetworkInterface | where { $_.Id -eq $vm.NetworkInterfaceIDs }
    Write-Output ("Get-AzNetworkSecurityGroup for " + $vm.Name + ":")
    Get-AzNetworkSecurityGroup | where { $_.Id -eq $ni.NetworkSecurityGroup.Id }
}

# Show the SQL Info
Write-Output ("", " SQL ","=====")
foreach ($rg in Get-AzResourceGroup)
{
    foreach($ss in Get-AzSqlServer -ResourceGroupName $rg.ResourceGroupName)
	{
		Write-Output ("Get-AzSqlServer -ServerName" + $ss.ServerName + " -ResourceGroupName " + $rg.ResourceGroupName)
		Get-AzSqlServer -ServerName $ss.ServerName -ResourceGroupName $rg.ResourceGroupName

		Write-Output ("Get-AzSqlDatabase -ServerName" + $ss.ServerName + " -ResourceGroupName " + $rg.ResourceGroupName)
		Get-AzSqlDatabase -ServerName $ss.ServerName -ResourceGroupName $rg.ResourceGroupName

		Write-Output ("Get-AzSqlServerFirewallRule -ServerName" + $ss.ServerName + " -ResourceGroupName " + $rg.ResourceGroupName)
		Get-AzSqlServerFirewallRule -ServerName $ss.ServerName -ResourceGroupName $rg.ResourceGroupName

		Write-Output ("Get-AzSqlServerThreatDetectionPolicy -ServerName" + $ss.ServerName + " -ResourceGroupName " + $rg.ResourceGroupName)
		Get-AzSqlServerThreatDetectionPolicy -ServerName $ss.ServerName -ResourceGroupName $rg.ResourceGroupName
	}
}