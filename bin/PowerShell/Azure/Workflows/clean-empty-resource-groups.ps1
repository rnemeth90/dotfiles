<#
    .SYNOPSIS
     A powershell workflow for searching all subscriptions
     in an Azure tenant for empty resource groups, and removing
     them if desired.
    .PARAMETER Mode
     The script currently accepts no parameters
    .EXAMPLE
     .
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0 - Initial
     Version 1.1 - Added retry logic for auth
#>
Import-Module AZ.Resources
# Set deleteUnattachedDisks=1 if you want to delete unattached Managed Disks
# Set deleteUnattachedDisks=0 if you want to see the Id of the unattached Managed Disks
$deleteEmptyResourceGroups=1
$connectionName = "AzureRunAsConnection"
# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process
$connection = Get-AutomationConnection -Name $connectionName

# Wrap authentication in retry logic for transient network failures
$logonAttempt = 1
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

$Subs = get-AzSubscription
#Loop through the subscriptions to find all empty Resource Groups and store them in $EmptyRGs
ForEach ($sub in $Subs) {
    Set-AzContext -SubscriptionId $sub.Id | Out-Null
    $AllRGs = (Get-AzResourceGroup).ResourceGroupName
    $UsedRGs = (Get-AzResource | Group-Object ResourceGroupName).Name
    $EmptyRGs = $AllRGs | Where-Object {$_ -notin $UsedRGs}

    #Loop through the empty Resorce Groups asking if you would like to delete them. And then deletes them.
    foreach ($EmptyRG in $EmptyRGs){
        if ($deleteEmptyResourceGroups -eq 1) {
            Write-Output "Deleting unused Resource Group named: $EmptyRG.Name"
            Remove-AzResourceGroup -Name $EmptyRG -Force
            Write-Output "Deleted unused Resource Group named: $EmptyRG.Name"
        }
        else{
            Write-Output "Did not delete any Resource Groups. Though, some were found."
        }
    }
}