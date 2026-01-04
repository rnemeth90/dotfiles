<#
    .SYNOPSIS
     This script will clone an existing virtual machine in Azure. It DOES NOT sysprep (Windows)
     the VM or remove the Azure VM Agent (Windows and Linux). These steps will need to be done
     manually before this script is executed.
    .PARAMETER SourceVmName
     The display name of the virtual machine to clone
    .PARAMETER DestinationVmName
     The display name of the virtual machine to create
    .PARAMETER DestinationResourceGroup
     The name of the resource group to create. This resource group will contain the virtual machine
     and all related resources (disk, network interface card, diagnostic settings, etc.)
    .PARAMETER DestinationLocation
     This is the location to create the virtual machine and associated resources in. (i.e. northcentralus)
    .EXAMPLE
     Clone-AzVm.ps1 -SourceVmName my-Vm -DestinationVmName my-New-Vm -DestinationResourceGroup my-rg -DestinationLocation northcentralus
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: https://www.geekyryan.com
    .LINK
     https://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>

[CmdletBinding()]
param (
    # Name of the VM to clone
    [Parameter(Mandatory=$true)]
    [String]$SourceVmName,
    # Name of the new VM
    [Parameter(Mandatory=$true)]
    [String]$DestinationVmName,
    # Resource Group name for the new VM
    [Parameter(Mandatory=$true)]
    [String]$DestinationResourceGroup,
    # Name of location for the new VM
    [Parameter(Mandatory=$true)]
    [String]$DestinationLocation
)

# DO NOT CHANGE ANY OF THESE
$nicName = $DestinationVmName+"-nic01"
$sourceVmObj = Get-AzVM -Name $SourceVmName
$vmSize = $sourceVmObj.HardwareProfile.VmSize
$SourceLocation = $sourceVmObj.Location
$SourceResourceGroup = $sourceVmObj.ResourceGroupName
$snapshotName = $SourceVmName+'-snapshot'


# Create the snapshot of the source VM OS disk
Write-Host "Creating snapshot of the disk..." -ForegroundColor Green
$disk = Get-AzDisk -ResourceGroupName $SourceResourceGroup -DiskName $sourceVmObj.StorageProfile.OsDisk.Name
$snapshotConfig =  New-AzSnapshotConfig -SourceUri $disk.Id -OsType Windows -CreateOption Copy -Location $SourceLocation
$snapShot = New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $SourceResourceGroup
$subnetId = (Get-AzNetworkInterface -ResourceId (get-azvm -name $sourceVmName).NetworkProfile.NetworkInterfaces.id).IpConfigurations.subnet.id

# Create the destination resource group for the destination VM
Write-Host "Creating a resource group for the new VM..." -ForegroundColor Green
New-AzResourceGroup -Location $DestinationLocation -Name $destinationResourceGroup

# Create the OS Disk for the destination VM
Write-Host "Creating the OS disk for the new VM..." -ForegroundColor Green
$osDiskName = $DestinationVmName+'-osDisk'
$osDisk = New-AzDisk -DiskName $osDiskName -Disk (New-AzDiskConfig  -Location $DestinationLocation -CreateOption Copy `
-SourceResourceId $snapshot.Id) -ResourceGroupName $destinationResourceGroup

# Create the NIC for the destination VM
Write-Host "Creating a new NIC for the VM..." -ForegroundColor Green
$nic = New-AzNetworkInterface -Name $nicName `
   -ResourceGroupName $destinationResourceGroup `
   -Location $DestinationLocation -SubnetId $subnetId

# Create the new VM
Write-Host "Creating the VM..." -ForegroundColor Green
$vmConfig = New-AzVMConfig -VMName $DestinationVmName -VMSize $vmSize
$vmObj = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$vmObj = Set-AzVMOSDisk -VM $vmObj -ManagedDiskId $osDisk.Id -StorageAccountType Standard_LRS -DiskSizeInGB 128 -CreateOption Attach -Windows
New-AzVM -ResourceGroupName $destinationResourceGroup -Location $DestinationLocation -VM $vmObj

# Output results
$vmList = Get-AzVM -ResourceGroupName $destinationResourceGroup
$vmList.Name