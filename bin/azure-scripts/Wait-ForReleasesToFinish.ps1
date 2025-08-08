function Get-Headers {
    if ( $Env:SYSTEM_ACCESSTOKEN ) {
        return @{
            Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
        }
    }
    elseif ($Env:VSTSTOKEN -and $Env:VSTSUSERNAME) {
        $User = $Env:VSTSUSERNAME
        $token = $Env:VSTSTOKEN
        $base64authinfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $User, $token)))
        return @{
            Authorization = ("Basic {0}" -f $base64authinfo)
        }
    }
    else {
        Write-Error "Couldn`'t find `$Env:SYSTEM_ACCESSTOKEN or `$Env:VSTSUSERNAME and `$Env:VSTSTOKEN"
    }
}

function Get-ReleaseStatus {
    param(
        [string]$releaseId,
        [string]$ProjectName
    )
    $releaseUrl ='https://marketingops.vsrm.visualstudio.com/{0}/_apis/release/releases/{1}?api-version=5.0-preview.6' -f $ProjectName, $releaseId

    $headers = Get-Headers

    $release = Invoke-RestMethod -Method Get -ContentType application/json -Uri $releaseUrl -Headers $headers

    $activeEnvironments = $release.environments | Where-Object { $_.status -ne 'succeeded' -and $_.status -ne 'rejected' -and $_.status -ne 'partiallySucceeded' -and $_.triggerReason -ne 'Manual' -and $_.status -ne 'canceled'} | Select-Object  @{ label='status'; expression={$_.status}}
    $rejectedEnvironments = $release.environments | Where-Object { $_.status -eq 'rejected' -or $_.status -eq 'canceled' } | Select-Object  @{ label='status'; expression={$_.status}}

    if ( $activeEnvironments.Length -gt 0) {
        $releaseProgressUrl ='https://dev.azure.com/marketingops/{0}/_releaseProgress?releaseId={1}' -f $ProjectName, $releaseId
        if ($null -ne $rejectedEnvironments) { 
            Write-Host "Release $releaseProgressUrl failed"
            return 'failed' 
        }
        
        Write-Host "Release $releaseProgressUrl is busy"
        return 'busy'
    }
    else {
        Write-Host "Release $releaseProgressUrl finished"
        return 'finished'
    }
}

$timeoutminutes = 80
$releaseIdCIP = $(ReleaseIdCIP)
$releaseIdDAM = $(ReleaseIdDAM)

$headers = Get-Headers

#Wait
$startDate = Get-Date
Write-Host "$('[{0:HH:mm}]' -f $startDate) polling release"
while ($true -and $startDate.AddMinutes($($timeoutminutes)) -gt (Get-Date)) {
    $statusDAM = Get-ReleaseStatus -releaseId "$releaseIdDAM" -ProjectName "adam"
    $statusCIP = Get-ReleaseStatus -releaseId "$releaseIdCIP" -ProjectName "PersonifyXP"
    
    if ($statusDAM -eq 'finished' -and $statusCIP -eq 'finished') { 
        break
    }
    elseif ($statusDAM -eq 'failed' -or $statusCIP -eq 'failed') {
        Write-Error '******READ THE LOGS!******** One or more release failed or partially failed...'
        break
    }

    Start-Sleep -Seconds 120
    Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) still polling"
}


Write-Host "Waiting 2 minutes before continuing on the fresh environments."
Start-Sleep -s 120
Write-Host "Finished."
