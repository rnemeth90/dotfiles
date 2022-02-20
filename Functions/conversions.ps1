function ConvertTo-Base64(){
	param(
		[Parameter(Mandatory=$true)]
		[string]$Value
	)
	$Bytes = [System.Text.Encoding]::UTF8.GetBytes($value)
 	$Base64 = [Convert]::ToBase64String($Bytes)
 	Write-Output $Base64
}

# This doesn't work :`(
function ConvertFrom-Base64(){
	param(
		[Parameter(Mandatory=$true)]
		[string]$Value
	)
	$DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Value))
	$DecodedText
}