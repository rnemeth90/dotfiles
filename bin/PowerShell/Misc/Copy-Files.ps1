<#
    .SYNOPSIS 
     This script uses robocopy to copy all files and directories from one location
     to another. It also copies all attributes, and will retry to copy files up to 5 times, 
     with a 15 second pause in between retries. It will avoid copying files from the source 
     that already exist in the destination, unless these files in the source are newer.
    .PARAMETER Mode
     This script accepts three mandatory parameters. They are self explanatory. 
     Just view the examples below. 
    .EXAMPLE
     Copy-Files.ps1 -Source c:\Source -Destination c:\Destination -Logdir c:\robocopy_logs\
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>

param(
    [Parameter(Mandatory=$true)]
    [String]$Source,
    [Parameter(Mandatory=$true)]
    [String]$Destination,
    [Parameter(ParameterSetName='Logging',Mandatory=$True)]
    [bool]$CreateLog,
    [Parameter(ParameterSetName='Logging')]
    [string]$logDir
)


$computerName = $env:computerName
$date = get-date -format M.d.yyyy
$logFile = "robocopy.log"
$logName = $date+"_"+$logFile

if ($CreateLog -eq $true){
    New-Item -Type directory -Path "c:\robocopy_logs" -Force 
    ROBOCOPY $source $destination /E /COPYALL /Z /R:5 /W:15 /XO /A-:SH | tee c:\robocopy_logs\$logName
}
else {
    ROBOCOPY $source $destination /E /COPYALL /Z /R:5 /W:15 /XO /A-:SH
}