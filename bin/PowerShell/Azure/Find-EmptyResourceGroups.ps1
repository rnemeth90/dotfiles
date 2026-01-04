
$subId = ""
$key = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds"
Set-ItemProperty $key ConsolePrompting $True
$loginErr = ""

#Auth to Azure
try {
    $cred = get-credential -Message "Azure Admin Credentials:" `n
    Login-AzAccount -Credential $cred -ErrorVariable $loginErr
catch {
    Write-Host "Message: [$($_.Exception.Message)"] -ForegroundColor Red `n
}
finally {
    #clean up variables
    $loginErr = null
    $cred = null
}


#verify variables
if ($subId -eq "") {
    $subId = Read-Host -Prompt "SubscriptionID: "
}

#Set 
Set-AzContext -SubscriptionId $subId

#Get all resource groups in the subscription
$resGroups = Get-AzResourceGroup


#Find all empty resource groups
foreach ($group in $resGroups) {
    $res = Get-AzResource | Where {$_.ResourceGroupName –eq $group.ResourceGroupName}
    $name = $group.ResourceGroupName
    if ($res.count -eq 0) {
        write-host "$name is empty"
    }
}
