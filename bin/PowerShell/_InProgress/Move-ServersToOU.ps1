foreach($server in $servers)
{
    $obj = Get-ADObject -Filter $server
    Move-ADObject -Identity $obj -TargetPath $ou -WhatIf
}