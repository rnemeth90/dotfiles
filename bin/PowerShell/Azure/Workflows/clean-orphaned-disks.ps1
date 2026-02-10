# Set deleteUnattachedDisks=1 if you want to delete unattached Managed Disks
# Set deleteUnattachedDisks=0 if you want to see the Id of the unattached Managed Disks
Import-Module AZ.Accounts
Import-Module AZ.Storage

$connectionName = "AzureRunAsConnection"
# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process
$connection = Get-AutomationConnection -Name $connectionName


# Wrap authentication in retry logic for transient network failures
$logonAttempt = 0
while(!($connectionResult) -and ($logonAttempt -le 10)){
    $LogonAttempt++
    # Logging in to Azure...
    $connectionResult = Connect-AzAccount `
                            -ServicePrincipal `
                            -Tenant $connection.TenantID `
                            -ApplicationId $connection.ApplicationID `
                            -CertificateThumbprint $connection.CertificateThumbprint

    Start-Sleep -Seconds 30
}

$deleteUnattachedDisks=1
$managedDisks = Get-AzDisk | Where-Object Id -NotLike "*asr*"
foreach ($disk in $managedDisks) {
    # ManagedBy property stores the Id of the VM to which Managed Disk is attached to
    # If ManagedBy property is $null then it means that the Managed Disk is not attached to a VM
    if($disk.ManagedBy -eq $null){
        if($deleteUnattachedDisks -eq 1){
            Write-Output "Deleting unattached Managed Disk with Id: $($disk.Id)"
            $disk | Remove-AzDisk -Force
            Write-Output "Deleted unattached Managed Disk with Id: $($disk.Id) "
        }else{
            Write-Output "Did not delete any disks. Though, orphaned disks were found."
        }
    }
    else{
        #Write-Output "Did not find any orphaned disks."
    }
}
