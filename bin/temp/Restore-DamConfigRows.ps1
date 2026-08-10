#Requires -Version 7.0
<#
.SYNOPSIS
    Action 1 (Bug #607798): Restore blanked DAM feature-flag config rows
    (incl. PublicCDNPassPhrase) back to their pre-Data-Tier-Phase-3 backup values
    across all affected tenants:*-rc partitions (686 rows / 79 keys / 31 RC-ring
    tenants -- automation, QA, perf, load-test, delivery, SSO, API-test, etc.).
    No production tenants are affected -- every impacted PartitionKey ends in "-rc".

.DESCRIPTION
    Reuses the data-tier pipeline's supported write path (Set-AprimoConfiguration
    action -> Set-TableStorageValue provider) instead of running the full
    orchestrator, to minimize blast radius to exactly the rows in the CSV.

.PARAMETER CsvPath
    CSV with columns: PartitionKey, RowKey, Value (defaults to bug607798-restore-rows.csv).

.PARAMETER ConfigTableStorageAccount
    The RC/vNext storage account hosting the modamautomation*-rc tenants config table.
    NEVER point this at a prod-* storage account.

.EXAMPLE
    # Dry run first
    pwsh ./Restore-DamConfigRows.ps1 -ConfigTableStorageAccount rc49us1<ring>appconfigsa -WhatIf

    # Then execute for real
    pwsh ./Restore-DamConfigRows.ps1 -ConfigTableStorageAccount rc49us1<ring>appconfigsa
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$CsvPath = (Join-Path $PSScriptRoot "bug607798-restore-rows-all-tenants.csv"),
    [Parameter(Mandatory)] [string]$ConfigTableStorageAccount
)

$ErrorActionPreference = 'Stop'
$dataTierRoot = "$HOME/repos/aprimo/marketingoperations/pipelines/02-data-tier/code"

Import-Module (Join-Path $dataTierRoot "_providers/Providers.psd1") -Force
Import-Module (Join-Path $dataTierRoot "common/utility/Utility.psd1") -Force
. (Join-Path $dataTierRoot "_actions/validation/Confirm-ActionIsValid.ps1")

$handler = Join-Path $dataTierRoot "_actions/Set-AprimoConfiguration.ps1"

$Variables = @{
    ConfigTableStorageAccount = $ConfigTableStorageAccount
    Environment               = 'rc'
}

$rows = Import-Csv -Path $CsvPath

$expected = 686
if ($rows.Count -ne $expected) {
    Write-Warning "Expected $expected rows, found $($rows.Count). Double-check CSV before proceeding."
}

$results = foreach ($row in $rows) {
    if ($row.PartitionKey -notmatch '^tenants:.*-rc$') {
        Write-Warning "Skipping unexpected PartitionKey (not an RC-ring tenant): $($row.PartitionKey)"
        continue
    }

    $action = @{
        Type      = 'Set-AprimoConfiguration'
        Key       = "$($row.PartitionKey):$($row.RowKey)"
        Value     = $row.Value
        Overwrite = $true
    }

    try {
        & $handler -Action $action -Variables $Variables -WhatIf:$WhatIfPreference -Verbose
        [PSCustomObject]@{ PartitionKey = $row.PartitionKey; RowKey = $row.RowKey; Status = 'OK' }
    }
    catch {
        [PSCustomObject]@{ PartitionKey = $row.PartitionKey; RowKey = $row.RowKey; Status = "FAILED: $_" }
    }
}

$results | Group-Object Status | Select-Object Name, Count
$results | Where-Object { $_.Status -ne 'OK' } | Format-Table -AutoSize
