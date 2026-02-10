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

$deleteUnusedNsgs=0
$nsgs = Get-AzNetworkSecurityGroup
foreach ($nsg in $nsgs){
    if ($deleteUnusedNsgs -eq 1){
        Write-Output "Deleting unused Network Security Group with Id: $($nsg.Id)"
        $nsg | Remove-AzNetworkSecurityGroup -Force
        Write-Output "Deleted unused Network Security Group with Id: $($nsg.Id) "
    }
    else{
        Write-Output "Did not delete any NSGs. Though, some were found."
        Write-Host "This NSG isn't used: " $nsg.Name
    }
}