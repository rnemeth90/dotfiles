<#
    .SYNOPSIS 
     vMotions virtual machines on a specified cluster to a specified datastore 
    .PARAMETER Mode
     This script accepts no parameters.
    .EXAMPLE
     Bulk-vMotionVms.ps1
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>

#Name of vCenter Server
[String]$vCenterSrv = "SBDVISP01"
#Name of datastore
[String]$datastore = "Internal-01"
#Name of Cluster 
[String]$cluster = "Internal"
#Virtual Machines to Exclude
[bool]$excludeVms = $true
$exclusionList = @("SBDVISP01",
                    "ksv-sbdesxp02-ecimain-ecipay-com",
                    "ksv-sbdesxp09-ecimain-ecipay-com",
                    "ksv-sbdesxp10-ecimain-ecipay-com",
                    "ksv-sbdesxp26-ecimain-ecipay-com")

#Import All VMWare Modules
get-module | Where-Object name -like *vm* | import-module

#Connect to vCenter Server
Connect-ViServer -Server $vCenterSrv -Credential (Get-Credential)

if($excludeVms -eq $true){
    $vms = Get-cluster $cluster | get-vm | Where-Object name -NotLike $excludedVm
    foreach($vm in $vms){
          move-vm -VM $vm -datastore $datastore -DiskStorageFormat Thin -RunAsync 
    }
}
else{
    #vMotion the virtual machines to the new datastore
    get-cluster $cluster | get-vm | move-vm -datastore $datastore -DiskStorageFormat Thin -RunAsync 
}

