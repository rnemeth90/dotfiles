$users = Get-Content .\users.txt
$attribute = "vibe"

foreach($user in $users){
    Write-Host "Setting customattribute1 to $attribute for $user"
    set-remotemailbox -identity $user -customattribute1 $attribute
}


Get-emailaddresspolicy | Update-emailaddresspolicy | Out-Null