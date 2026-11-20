#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication
<#
.SYNOPSIS
    Adds a common owner to all (or filtered) Entra ID groups.

.PARAMETER Owner
    UPN or object ID of the user to add as owner.

.PARAMETER Filter
    Optional OData $filter for groups, e.g. "securityEnabled eq true".

.PARAMETER BatchSize
    Number of groups to process per batch. 0 (default) processes all in one batch.

.PARAMETER BatchDelaySeconds
    Seconds to pause between batches (useful for throttling). Default 0.

.PARAMETER RemoveOtherOwners
    After ensuring -Owner is an owner, remove every other owner from each group.
    Use -DryRun first. Groups synced from on-premises AD are skipped.

.PARAMETER DryRun
    Report what would change without making any changes.

.EXAMPLE
    ./Set-EntraGroupOwner.ps1 -Owner admin@contoso.com -DryRun

.EXAMPLE
    ./Set-EntraGroupOwner.ps1 -Owner admin@contoso.com -BatchSize 50 -BatchDelaySeconds 10 -Filter "startswith(displayName,'Team-')"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Owner,
    [string]$Filter,
    [ValidateRange(0, [int]::MaxValue)][int]$BatchSize = 0,
    [ValidateRange(0, 3600)][int]$BatchDelaySeconds = 0,
    [switch]$RemoveOtherOwners,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

Connect-MgGraph -Scopes 'Group.ReadWrite.All', 'User.Read.All' -NoWelcome | Out-Null

$ownerUser = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$([uri]::EscapeDataString($Owner))?`$select=id,userPrincipalName"
Write-Host "Owner: $($ownerUser.userPrincipalName) ($($ownerUser.id))"
if ($DryRun) { Write-Host '*** DRY RUN: no changes will be made ***' -ForegroundColor Yellow }

$uri = 'https://graph.microsoft.com/v1.0/groups?$select=id,displayName,onPremisesSyncEnabled&$top=999'
$headers = @{}
if ($Filter) {
    $uri += '&$filter=' + [uri]::EscapeDataString($Filter) + '&$count=true'
    $headers['ConsistencyLevel'] = 'eventual'
}

$groups = @()
while ($uri) {
    $page = Invoke-MgGraphRequest -Method GET -Uri $uri -Headers $headers
    $groups += $page.value
    $uri = $page.'@odata.nextLink'
}
Write-Host "Groups found: $($groups.Count)"

$stats = @{ Added = 0; WouldAdd = 0; AlreadyOwner = 0; Removed = 0; WouldRemove = 0; Skipped = 0; Failed = 0 }

$size = if ($BatchSize -gt 0) { $BatchSize } else { [Math]::Max($groups.Count, 1) }
$batchCount = [Math]::Ceiling($groups.Count / $size)
$index = 0

foreach ($g in $groups) {
    if ($index % $size -eq 0) {
        $batchNo = [int]($index / $size) + 1
        if ($batchNo -gt 1 -and $BatchDelaySeconds -gt 0) {
            Write-Host "Waiting $BatchDelaySeconds s before next batch..."
            Start-Sleep -Seconds $BatchDelaySeconds
        }
        Write-Host "--- Batch $batchNo of $batchCount ---" -ForegroundColor Magenta
    }
    $index++

    $label = "$($g.displayName) [$($g.id)]"
    try {
        if ($g.onPremisesSyncEnabled) {
            Write-Warning "Skipping on-premises synced group: $label"
            $stats.Skipped++
            continue
        }

        $owners = @()
        $ownersUri = "https://graph.microsoft.com/v1.0/groups/$($g.id)/owners?`$select=id,displayName,userPrincipalName&`$top=999"
        while ($ownersUri) {
            $p = Invoke-MgGraphRequest -Method GET -Uri $ownersUri
            $owners += $p.value
            $ownersUri = $p.'@odata.nextLink'
        }

        $isOwner = $owners.id -contains $ownerUser.id

        if ($isOwner) {
            Write-Host "Already owner: $label"
            $stats.AlreadyOwner++
        }
        elseif ($DryRun) {
            Write-Host "[DryRun] Would add owner to: $label" -ForegroundColor Cyan
            $stats.WouldAdd++
        }
        else {
            $body = @{ '@odata.id' = "https://graph.microsoft.com/v1.0/users/$($ownerUser.id)" } | ConvertTo-Json
            Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/groups/$($g.id)/owners/`$ref" -Body $body -ContentType 'application/json' | Out-Null
            Write-Host "Added owner to: $label" -ForegroundColor Green
            $stats.Added++
        }

        if ($RemoveOtherOwners) {
            foreach ($o in @($owners | Where-Object { $_.id -ne $ownerUser.id })) {
                $oLabel = "$($o.userPrincipalName ?? $o.displayName ?? $o.id) [$($o.id)] from $label"
                if ($DryRun) {
                    Write-Host "[DryRun] Would remove owner $oLabel" -ForegroundColor Cyan
                    $stats.WouldRemove++
                }
                else {
                    Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/groups/$($g.id)/owners/$($o.id)/`$ref" | Out-Null
                    Write-Host "Removed owner $oLabel" -ForegroundColor Green
                    $stats.Removed++
                }
            }
        }
    }
    catch {
        Write-Warning "Failed on $label : $($_.Exception.Message)"
        $stats.Failed++
    }
}

Write-Host ''
Write-Host "Summary: Added=$($stats.Added) WouldAdd=$($stats.WouldAdd) AlreadyOwner=$($stats.AlreadyOwner) Removed=$($stats.Removed) WouldRemove=$($stats.WouldRemove) Skipped=$($stats.Skipped) Failed=$($stats.Failed)"
