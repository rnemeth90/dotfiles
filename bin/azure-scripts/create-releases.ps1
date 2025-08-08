function Get-Headers {
	if ( $Env:SYSTEM_ACCESSTOKEN ) {
		return @{
			Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
		}
	}
	elseif ($Env:VSTSTOKEN -and $Env:VSTSUSERNAME) {
		Write-Warning "Using VSTSTOKEN and VSTSUSERNAME variable from `$ENV"
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

function Get-ReleaseInfo {
	param(
		[Parameter(Mandatory = $true)][int]$releaseId,
		[Parameter(Mandatory = $true)][string]$projectName
	)
	$headers = Get-Headers
	$ReleaseUri = "https://vsrm.dev.azure.com/marketingops/($projectName)/_apis/release/releases/$($releaseId)?api-version=5.1"

	$releaseFromGet = Invoke-RestMethod -Method Get -ContentType application/json -Uri $ReleaseUri -Headers $headers
	Write-Verbose $releaseFromGet.id

	return @{
		'artifacts' = $releaseFromGet.artifacts
		'variables' = $releaseFromGet.variables
	}
}

function New-Release() {
	param(
		[Parameter(Mandatory = $true)]$artifacts,
		[Parameter(Mandatory = $true)]$variables,
		[Parameter(Mandatory = $true)]$type
	)

	# map the artifacts

	$prefix = '{0}.' -f $type
	$filter = '{0}.*' -f $type

	$releaseArtifacts = $artifacts | Where-Object { $_.alias -like $filter } | ForEach-Object {
		return @{
			'alias'             = $_.alias.Replace($prefix, '')
			'instanceReference' = @{
				'id'   = $_.definitionReference.version.id
				'name' = $_.definitionReference.version.name
			}
		}
	}

	# map shared artifacts
	$releaseArtifacts += $artifacts | Where-Object { $_.alias -like 'ALL.*' } | ForEach-Object {
		return @{
			'alias'             = $_.alias.Replace('ALL.', '')
			'instanceReference' = @{
				'id'   = $_.definitionReference.version.id
				'name' = $_.definitionReference.version.name
			}
		}
	}

	$tenant = $variables.tenant.value
  $shutDownTimeUtc = $variables.ShutDownTimeUtc.value
	$email = if ("$(NotificationEmailAddress)") { "$(NotificationEmailAddress)" } else { "$(Release.Deployment.RequestedForEmail)" }
	$reuseLab = $variables.reuseLab.value
	$reuseLab = if ($reuseLab -eq "true") { "true" } else { "false" }
	$UploadServiceNewVersion = $variables.UploadServiceNewVersion.value
	$UploadServiceNewVersion = if ($UploadServiceNewVersion -eq "true") { "true" } else { "false" }

	# map the variables to dam release
	if ($type -eq 'DAM') {
		$releaseVariables = @{
			'Cluster'         = @{ 'value' = 'c' + $tenant }
			'Customer'        = @{ 'value' = 'g' + $tenant }
			'reuseCluster'    = @{ 'value' = "$reuseLab" }
			'ShutDownTimeUtc' = @{ 'value' = $shutDownTimeUtc }
      'LabOwner'        = @{ 'value' = $email }
		}
	}

	if ($type -eq 'CIP') {
		$releaseVariables = @{
			'DAMTenantId'                 = @{ 'value' = $tenant }
      'DAMIntegration         '     = @{ 'value' = "true" }
			'labId'                       = @{ 'value' = $tenant }
			'reUseLab'                    = @{ 'value' = "$reuseLab" }
			'LabAutomaticShutDownUTCTime' = @{ 'value' = $shutDownTimeUtc }
			'NotificationEmailAddress'    = @{ 'value' = "$email" }
		}
	}

	# generic mapping of variables
  $variables | Get-Member -MemberType NoteProperty | Where-Object { $_.Name -like $filter } | ForEach-Object {
       $key = $_.Name
       $mappedKey = $key.Replace($prefix, '')  # e.g., DAM.DeleteData → DeleteData

       # Only add if the key doesn't already exist
       if (-not $releaseVariables.ContainsKey($mappedKey)) {
             $releaseVariables.Add($mappedKey, @{ 'value' = $variables.$key.value })
       }
    }

	$jsoncontent = @{
		'description' = "Integrated Lab: $($tenant)"
		'artifacts'   = $releaseArtifacts
		'variables'   = $releaseVariables
	}

	if ($type -eq 'DAM') {
		$jsoncontent.definitionId = '329'
		$jsoncontent = $jsoncontent | ConvertTo-Json -Depth 100

		$Uri = "https://marketingops.vsrm.visualstudio.com/adam/_apis/release/releases/?api-version=5.0-preview.6"
	}

	if ($type -eq 'CIP') {
		$jsoncontent.definitionId = '7'
		$jsoncontent = $jsoncontent | ConvertTo-Json -Depth 100

		$Uri = "https://marketingops.vsrm.visualstudio.com/PersonifyXP/_apis/release/releases/?api-version=5.0-preview.6"
	}

	# create the actual release
	$headers = Get-Headers
	$releaseresponse = Invoke-RestMethod -Method Post -Uri $Uri -Headers $headers -ContentType "application/json" -Body $jsonContent

	$releaseId = $releaseresponse.id

	return $releaseId
}

$currentReleaseId = "$(Release.ReleaseId)"

#getting $artifacts of currently executing release
$releaseInfo = Get-ReleaseInfo -ReleaseId $currentReleaseId

$damReleaseId = New-Release -type 'DAM' -artifacts $releaseInfo.artifacts -variables $releaseInfo.variables
Write-Host "##vso[task.setvariable variable=ReleaseIdDAM]$damReleaseId"

$cipReleaseId = New-Release -type 'CIP' -artifacts $releaseInfo.artifacts -variables $releaseInfo.variables
Write-Host "##vso[task.setvariable variable=ReleaseIdCIP]$cipReleaseId"
