param (
    #The subscription ID
    [Parameter(Mandatory=$True)]
    [String]$SubscriptionId,
    #The resource group of the VM
    [Parameter(Mandatory=$True)]
    [String]$ResourceGroupName,
    [Parameter(Mandatory=$True)]
    [String]$vmName,
    [Parameter(Mandatory=$True)]
    [String]$KeyVaultName
)


#Connect to Azure
try {
    Connect-AzAccount -ErrorAction Stop
}
catch {
    Write-Output "Unable to connect to Azure"
}

#Set the context
try {
    Set-AzContext -SubscriptionId $SubscriptionId
}
catch {
    Write-Output "Invalid subscription context"
}

$vaultResourceGroup = (Get-AzKeyVault -name $keyVaultName).resourcegroupname

#Grant ourselves permission to AZ Key keyVaultNameGet-AzADUser
$objID=(Get-AzADUser -UserPrincipalName (Get-AzContext).Account).Id
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $vaultResourceGroup -ObjectId $objID -PermissionsToKeys create,delete,list,get,verify,encrypt,wrapkey

#Create a software encryption key in the Key Vault
Add-AzKeyVaultKey -VaultName $keyVaultName -Name "$vmName-encryptionKey" -Destination "Software"

#Check AZ VM Status, running, not encrypted
Get-AzVM -ResourceGroupName $resourceGroupName -VMName $vmName -Status |  Select-Object Name, @{n="Running Status"; e={$_.Statuses[1].DisplayStatus}}

#Gather some variables from the keyvault
$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $vaultResourceGroup
$diskEncryptionKeyVaultUrl = $keyVault.VaultUri
$keyVaultResourceId = $keyVault.ResourceId
$keyEncryptionKeyUrl = (Get-AzKeyVaultKey -VaultName $keyVaultName -Name "$vmName-encryptionKey").Key.kid

#Configure disk encryption for the VM
Set-AzVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName $vmName -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -KeyEncryptionKeyUrl $keyEncryptionKeyUrl -KeyEncryptionKeyVaultId $keyVaultResourceId



