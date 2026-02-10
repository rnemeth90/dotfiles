#Replace with the old suffix
$oldSuffix = 'old.suffix'

#Replace with the new suffix
$newSuffix = 'new.suffix'

#Replace with the OU you want to change suffixes for
$ou = "DC=sample,DC=domain"

#Replace with the name of your AD server
$server = "test"

Get-ADUser -SearchBase $ou -filter * | ForEach-Object {
$newUpn = $_.UserPrincipalName.Replace($oldSuffix,$newSuffix)
$_ | Set-ADUser -server $server -UserPrincipalName $newUpn
}