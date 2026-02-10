Param(
[string]$organisation = "",
   [string]$project = "",
   [string]$user = "",
   [string]$token = ""
)

# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))


function CreateJsonBody
{

$value = @"

{"searchText":"chrony",
"filters":"{\"ProjectFilters\":[\"ProjectName\"]}",
"`$top":100
}

"@

return $value
}

$json = CreateJsonBody

$postresults = "https://almsearch.dev.azure.com/$organisation/$project/_apis/search/codesearchresults?api-version=6.0-preview.1"

Write-Host $postresults
$result = Invoke-RestMethod -Uri $postresults -Method Post -Body $json -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

$result = $result | convertto-json

Write-host $result
