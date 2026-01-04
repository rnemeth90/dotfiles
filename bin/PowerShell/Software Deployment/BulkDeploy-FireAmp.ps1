<#
    .SYNOPSIS 
     Deploys the FireAmp agent to multiple computers and installs silently.  
    .PARAMETER Mode
     This script accepts no parameters. 
    .EXAMPLE
     BulkDeploy-FireAmp 
    .NOTES
     Author: Ryan Nemeth - rnemeth@tmcrv.com
    .LINK
    .DESCRIPTION
     Version 1.0
    .EXAMPLE
     BulkDeploy-FireAmp 
#>

#$computers = get-adcomputer -filter * | select name | Where-Object name -like *acc*

$computers = Get-Content C:\FireAmpDeploy\Computers.txt

$i = 0

foreach($computer in $computers){
    mkdir \\$computer\c$\FireAmpInstaller
    copy-item  "\\install\install\Fireamp\Protect_FireAMPSetup.exe"  "\\$computer\c$\FireAmpInstaller\Protect_FireAMPSetup.exe"

    Write-Progress -activity "Installing FireAmp . . ." -status "Deployed: $i of $($computers.Count)" -percentComplete (($i / $computers.Count)  * 100)
    PsExec.exe -s \\$computer c:\FireAppInstaller\Protect_FireAMPSetup.exe /S
}


