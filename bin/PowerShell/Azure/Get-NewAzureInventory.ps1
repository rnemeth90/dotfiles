<#
.SYNOPSIS
  Gets a list of all recently created resources across all subscriptions
  and send a report via email
.DESCRIPTION
    This script is hosted in an Azure Automation account.
.INPUTS
  None
.OUTPUTS
  Report sent via email
.NOTES
  Version:        1.0
  Author:         Ryan Nemeth
  Creation Date:  01/03/2021
  Purpose/Change: Initial script development
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

workflow Get-NewAzureInventory {
    param (
        # SHOULD WE PARAM ANYTHING ????
    )

    # az automation account connection name
    $connectionName = "AzureRunAsConnection";

    try {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection = Get-AzAutomationConnection -Name $connectionName

        "Logging in to Azure..."
        Connect-AzAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }

    try {
        Get-AzLog -StartTime (Get-Date).AddHours(-24)
    }
    catch {

    }


}