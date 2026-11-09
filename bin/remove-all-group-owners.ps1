<#
.SYNOPSIS
    Removes every owner from every Azure AD (Entra ID) group in the current tenant,
    with automatic backup and a restore mode.

.DESCRIPTION
    Remove mode (default):
      Iterates all groups returned by Get-AzADGroup, lists their current owners via
      Get-AzADGroupOwner, and removes each owner via Remove-AzADGroupOwner.
      Before each removal, the owner is appended to a backup CSV so a crash part-way
      through still leaves a usable backup. No backup is written with -WhatIf.

    Restore mode (-RestoreFrom <csv>):
      Reads a backup CSV and re-adds each owner to its group via New-AzADGroupOwner.
      Owners that are already present are reported and skipped. The backup is tied to
      the tenant it was taken from; restore refuses to run against a different tenant.

    This is a destructive, tenant-wide operation. Groups with zero owners can become
    unmanageable (no one can approve membership changes) unless ownership is
    reassigned elsewhere (e.g. via a PIM/admin role) first.

    Restore limitations: it restores owner links only. Groups that were deleted, or
    owner objects that were deleted since the backup, cannot be restored.

.PARAMETER BackupPath
    Where to write the backup CSV in remove mode.
    Default: ./group-owners-backup-<tenantId>-<yyyyMMdd-HHmmss>.csv

.PARAMETER RestoreFrom
    Path of a backup CSV. Switches the script into restore mode.

.PARAMETER WhatIf
    Dry-run: logs what would be removed/restored without making any changes (and
    without writing a backup). Strongly recommended to run this first.

.EXAMPLE
    # Dry run - see what would happen, no changes made
    ./remove-all-group-owners.ps1 -WhatIf

.EXAMPLE
    # Remove all owners from all groups (backup is written automatically)
    ./remove-all-group-owners.ps1

.EXAMPLE
    # Preview, then perform, a restore
    ./remove-all-group-owners.ps1 -RestoreFrom ./group-owners-backup-<...>.csv -WhatIf
    ./remove-all-group-owners.ps1 -RestoreFrom ./group-owners-backup-<...>.csv
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$BackupPath,
    [string]$RestoreFrom
)

$ErrorActionPreference = "Stop"

$context = Get-AzContext
if (-not $context) {
    throw "Not logged in. Run Connect-AzAccount first."
}
$tenantId = $context.Tenant.Id

# ------------------------------------------------------------------ restore mode
if ($RestoreFrom) {
    if (-not (Test-Path $RestoreFrom)) {
        throw "Backup file not found: $RestoreFrom"
    }

    $rows = Import-Csv -Path $RestoreFrom
    Write-Host "Loaded $($rows.Count) owner entries from $RestoreFrom."

    $backupTenants = @($rows.TenantId | Where-Object { $_ } | Select-Object -Unique)
    if ($backupTenants.Count -gt 1 -or ($backupTenants.Count -eq 1 -and $backupTenants[0] -ne $tenantId)) {
        throw "Backup tenant ($($backupTenants -join ', ')) does not match current tenant ($tenantId). Aborting."
    }

    $results = foreach ($row in $rows) {
        $target = "$($row.Group) ($($row.GroupId))"
        if ($PSCmdlet.ShouldProcess($target, "Restore owner $($row.Owner)")) {
            try {
                New-AzADGroupOwner -GroupId $row.GroupId -OwnerObjectId $row.OwnerId -ErrorAction Stop
                $action = "RESTORED"
            }
            catch {
                if ($_.Exception.Message -match "already exist") { $action = "SKIPPED (already an owner)" }
                else { $action = "ERROR: $($_.Exception.Message)" }
            }
        }
        else {
            $action = "WOULD RESTORE (WhatIf)"
        }

        [PSCustomObject]@{
            Group   = $row.Group
            GroupId = $row.GroupId
            Owner   = $row.Owner
            OwnerId = $row.OwnerId
            Action  = $action
        }
    }

    $results | Format-Table -AutoSize -Wrap
    $resultPath = "./restore-group-owners-result.csv"
    $results | Export-Csv -Path $resultPath -NoTypeInformation -WhatIf:$false
    Write-Host "Full results written to $resultPath"
    return
}

# ------------------------------------------------------------------- remove mode
if (-not $BackupPath) {
    $BackupPath = "./group-owners-backup-$tenantId-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
}
if ($WhatIfPreference) {
    Write-Host "WhatIf: no changes will be made and no backup will be written."
}
else {
    Write-Host "Backup will be written to $BackupPath"
}

$groups = Get-AzADGroup
Write-Host "Found $($groups.Count) groups."

$results = foreach ($group in $groups) {
    $owners = Get-AzADGroupOwner -GroupId $group.Id -ErrorAction SilentlyContinue
    if (-not $owners) {
        [PSCustomObject]@{
            Group       = $group.DisplayName
            GroupId     = $group.Id
            Owner       = $null
            OwnerId     = $null
            Action      = "SKIPPED (no owners)"
        }
        continue
    }

    foreach ($owner in $owners) {
        $ownerLabel = $owner.DisplayName
        if (-not $ownerLabel) { $ownerLabel = $owner.UserPrincipalName }
        if (-not $ownerLabel) { $ownerLabel = $owner.Id }

        if ($PSCmdlet.ShouldProcess("$($group.DisplayName) ($($group.Id))", "Remove owner $ownerLabel")) {
            try {
                # Back up first: if this line fails, the owner is NOT removed.
                [PSCustomObject]@{
                    TenantId = $tenantId
                    Group    = $group.DisplayName
                    GroupId  = $group.Id
                    Owner    = $ownerLabel
                    OwnerId  = $owner.Id
                } | Export-Csv -Path $BackupPath -Append -NoTypeInformation -WhatIf:$false

                Remove-AzADGroupOwner -GroupId $group.Id -OwnerObjectId $owner.Id -ErrorAction Stop
                [PSCustomObject]@{
                    Group   = $group.DisplayName
                    GroupId = $group.Id
                    Owner   = $ownerLabel
                    OwnerId = $owner.Id
                    Action  = "REMOVED"
                }
            }
            catch {
                [PSCustomObject]@{
                    Group   = $group.DisplayName
                    GroupId = $group.Id
                    Owner   = $ownerLabel
                    OwnerId = $owner.Id
                    Action  = "ERROR: $($_.Exception.Message)"
                }
            }
        }
        else {
            [PSCustomObject]@{
                Group   = $group.DisplayName
                GroupId = $group.Id
                Owner   = $ownerLabel
                OwnerId = $owner.Id
                Action  = "WOULD REMOVE (WhatIf)"
            }
        }
    }
}

$results | Format-Table -AutoSize -Wrap
$results | Export-Csv -Path "./remove-all-group-owners-result.csv" -NoTypeInformation -WhatIf:$false
Write-Host "Full results written to ./remove-all-group-owners-result.csv"
if (-not $WhatIfPreference -and (Test-Path $BackupPath)) {
    Write-Host "Backup written to $BackupPath. To undo: ./remove-all-group-owners.ps1 -RestoreFrom $BackupPath"
}
