<#
.SYNOPSIS
Enable-VmwareToAsrReplication.ps1 -Enable ASR Replication for a single VM from vCenter to Azure

.DESCRIPTION 
This PowerShell script will enable Azure Site Recovery Replication for a single VM in a vCenter environment

.OUTPUTS
Results are output to a text log file.

.NOTES
Written by: Ryan Nemeth

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

Change Log
V1.00, 08/15/2019 - Initial version
#>

#Function for writing to log file
$logfile = ".\Enable-VmwareToAsrReplication.log"
function writeLog(){
    param(
        [String]$value1,
        [String]$value2,
        [String]$value3,
        [String]$value4
    )

    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 + $value2 + $value3 + $value4 | Out-File $logfile -Append
}

writelog ""
writelog "-------------------------"
writelog "Starting new run"
#some housekeeping tasks
writeLog "Connecting to Azure..."
Connect-AzAccount
writeLog "Setting context for the subscription..."
Set-AzContext -SubscriptionId "5e4bfeb2-2d37-4e4e-aa0c-5ab41fe19b2a" | Out-Null
writelog "Gathering ASR Vault information..."
$vault = Get-AzRecoveryServicesVault
Set-ASRVaultContext -Vault $vault | Out-Null
writeLog "Gathering ASR Fabric information..."
$ASRFabrics = Get-AzRecoveryServicesAsrFabric
#Get the target resource group to be used
writeLog "Setting the target resource group..."
$ResourceGroup = Get-AzResourceGroup -Name "int-rg-us-nc-asr-01"
#Get the target virtual network to be used
writeLog "Setting the target virtual network..."
Set-AzContext -SubscriptionId "72787baf-bb18-45db-8190-887f9d6b6894" | Out-Null
$RecoveryVnet = Get-AzVirtualNetwork -Name "prod-vn-us-nc-vnet-01" -ResourceGroupName "prod-rg-us-nc-net-01" 
Set-AzContext -SubscriptionId "5e4bfeb2-2d37-4e4e-aa0c-5ab41fe19b2a" | Out-Null
writelog "Gather Azure Site Recovery credentials for replication..."
$AccountHandles = $ASRFabrics[0].FabricSpecificDetails.RunAsAccounts

#Find all process servers in South Bend Datacenter
writeLog "Finding process servers in South Bend datacenter..."
$ProcessServers = $ASRFabrics[0].FabricSpecificDetails.ProcessServers

#Find a process server in South Bend Datacenter
writeLog "Prompting the user for a process server to use for replication..."
$usableProcessServers = $ProcessServers | Where-Object FriendlyName -Like "*SBD*" | Sort-Object
if ($usableProcessServers.count -gt 1){
    Write-Host "Multiple Process Servers were found" -ForegroundColor Yellow
    Write-Host "Please select a process server:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $usableProcessServers.Count; $i++) {
        Write-Host "$($i): $($usableProcessServers[$i].FriendlyName)" | Sort-Object
    }
    $selection = Read-Host -Prompt "Enter the number of the process server"
    $p_serverToUse = $usableProcessServers[$selection]
    writeLog "Using process server: $p_serverToUse.FriendlyName"
}  

#Get the protection container corresponding to the Configuration Server
writelog "Prompting the user for the protection policy to use..."
$ProtectionContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $ASRFabrics[0] | Sort-Object
#Get the protection container mapping for replication policy named ReplicationPolicy
$PolicyMap  = Get-AzRecoveryServicesAsrProtectionContainerMapping -ProtectionContainer $ProtectionContainer 
if ($PolicyMap.count -gt 1){
    Write-Host "Multiple Replication Policies were found" -ForegroundColor Yellow
    Write-Host "Please select a Replicatin Policy:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $PolicyMap.Count; $i++) {
        Write-Host "$($i): $($PolicyMap[$i].PolicyFriendlyName)" | Sort-Object
    }
    $selection = Read-Host -Prompt "Enter the number of the Replication Policy to use"
    $r_policyToUse = $PolicyMap[$selection]
    writeLog "Using policy: $r_policyToUse.FriendlyName"
}


#Get the protectable item corresponding to the vCenter virtual machines
writelog "Prompting the user for the virtual machine to replicate..."
$ProtectionContainer = Get-AzRecoveryServicesAsrProtectionContainer -Fabric $ASRFabrics[0]
$VMS = Get-AzRecoveryServicesAsrProtectableItem -ProtectionContainer $ProtectionContainer | Sort-Object
if ($VMS.count -gt 1){
    Write-Host "Multiple virtual machines were found" -ForegroundColor Yellow
    Write-Host "Please select a virtual machine:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $VMS.Count; $i++) {
        Write-Host "$($i): $($vms[$i].FriendlyName)" | Sort-Object
    }
    $selection = Read-Host -Prompt "Enter the number of the virtual machine to replicate"
    $r_VmToUse = $VMS[$selection]
    writelog "Virtual machine to replicate: $r_VmToUse.FriendlyName"
}

#Get Storage accounts
writeLog "Gathering the storage accounts available for Azure Site Recovery and selecting a random account..."
Set-AzContext -SubscriptionId "72787baf-bb18-45db-8190-887f9d6b6894" | Out-Null
$asrStorageAccounts = Get-AzStorageAccount | Where-Object StorageAccountName -Like "*asr*"
$saToUse = Get-Random -InputObject $asrStorageAccounts
Write-Host $saToUse

# Enable replication for virtual machine using the Az.RecoveryServices module 2.0.0
# The name specified for the replicated item needs to be unique within the protection container. Using a random GUID to ensure uniqueness
Set-AzContext -SubscriptionId "5e4bfeb2-2d37-4e4e-aa0c-5ab41fe19b2a" | Out-Null
writelog "Enabling replication for the selected virtual machine..."
writelog "Replicating: $r_VmToUse.FriendlyName"
$Job_EnableReplication1 = New-AzRecoveryServicesAsrReplicationProtectedItem -VMwareToAzure -ProtectableItem $r_VmToUse -Name (New-Guid).Guid -ProtectionContainerMapping $r_policyToUse -RecoveryAzureStorageAccountId $saToUse.Id -ProcessServer $p_serverToUse -Account $AccountHandles[0] -RecoveryResourceGroupId $ResourceGroup.ResourceId -logStorageAccountId $saToUse.Id -RecoveryAzureNetworkId $RecoveryVnet.Id -RecoveryAzureSubnetName "prod-sn-us-nc-bkup-01"
#writeLog $Job_EnableReplication1
$Job_EnableReplication1
