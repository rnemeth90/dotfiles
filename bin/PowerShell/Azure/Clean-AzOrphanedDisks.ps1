<#
    .SYNOPSIS
     Searches for all managed disks that have been detached
     from their parent VMs and removes them.
    .PARAMETER Mode
     The script currently accepts no parameters
    .EXAMPLE
     .\Clean-OrphanedDisks.ps1
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>

# Set deleteUnattachedDisks=1 if you want to delete unattached Managed Disks
# Set deleteUnattachedDisks=0 if you want to see the Id of the unattached Managed Disks
$deleteUnattachedDisks=0
$managedDisks = Get-AzDisk | Where-Object Id -NotLike "*asr*"
foreach ($disk in $managedDisks) {
    # ManagedBy property stores the Id of the VM to which Managed Disk is attached to
    # If ManagedBy property is $null then it means that the Managed Disk is not attached to a VM
    if($disk.ManagedBy -eq $null){
        if($deleteUnattachedDisks -eq 1){
            Write-Host "Deleting unattached Managed Disk with Id: $($disk.Id)"
            $disk | Remove-AzDisk -Force
            Write-Host "Deleted unattached Managed Disk with Id: $($disk.Id) "
        }else{
            $disk.Id
        }
    }
 }