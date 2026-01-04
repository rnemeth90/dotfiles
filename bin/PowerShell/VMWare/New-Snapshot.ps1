 $vmList = @("SBDEMPR12",
 "SBDVPWP05",
 "SBDVPWP08",
 "SBDVPWP09",
"SBDVPWD03"
)

$date=Get-Date
$viServer = "sbdvisp01"
$cred = Get-Credential
$modules = @("VMware.VimAutomation.Core")

foreach($module in $modules){
    Write-Host "Importing modules" -ForegroundColor Green
    Import-Module $module
}

Write-Host "Connect to vCenter" -ForegroundColor Green
Connect-VIServer -Server $viServer -Credential $cred | Out-Null

ForEach($vm in $vmList){
    Write-Host "Creating snapshot for " $vm -ForegroundColor Green
    New-Snapshot -VM $vm -Name $vm-$date | out-null
}

#add error handling