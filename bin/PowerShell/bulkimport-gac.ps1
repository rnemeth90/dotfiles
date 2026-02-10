$startPath = ".\productionDLLs"
set-location $startPath
$childDirs = Get-ChildItem -Recurse | ?{ $_.PSIsContainer }

foreach ($childDir in $childDirs) {
    Set-location -Path $childDir.Fullname
    #pwd
    $dlls = Get-ChildItem -Recurse -file
    #write-host $dlls
    foreach ($dll in $dlls) {
        #Write-Host $dll
        #write-host "importing $dll.fullname"
        $dllPath = $dll.fullname
        #write-host $dllpath
        $command = "c:\deployments_net_4.0\gacutil.exe /i $dllPath"
        Invoke-Expression -Command:$command
    }
}