$nsgs = Get-AzNetworkSecurityGroup

foreach ($nsg in $nsgs){
    if ($deleteUnusedNsgs -eq 1){
        Write-Output "Deleting unused Network Security Group with Id: $($nsg.Id)"
        $nsg | Remove-AzNetworkSecurityGroup -Force
        Write-Output "Deleted unused Network Security Group with Id: $($nsg.Id) "
    }
    else{
        Write-Output "Did not delete any disks. Though, orphaned disks were found."
        Write-Host "This NSG isn't used: " $nsg.Name
    }
}