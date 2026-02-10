#http://www.virtu-al.net/2009/08/14/powercli-do-you-have-the-time/

param(
# The vCenter Server to connect to
[Parameter(Mandatory=$true)]
[string]$vCenterServer,
# The NTP Server to Configure
[Parameter(Mandatory=$true)]
[string]$NtpServer
)

#Variables
$module = "VMware.VimAutomation.Core"
$ErrorActionPreference = "Stop"

#Remove the Hyper-V Module. It has duplicate cmdlets
if (Get-Module -Name Hyper-V) {
    Write-Host "Found Hyper-V Module. Unloading it from current PowerShell Session..." -ForegroundColor Red
    Remove-Module -Name Hyper-V -Force
    Start-Sleep -Seconds 2
    Clear-Host
}

#Import the module
if (!(Get-Module -Name $module)) {
    Write-Host "Module $module not loaded, attempting to load it now..." -ForegroundColor Red
    Import-Module -Name $module
}
else {
    Write-host "Module $module is loaded. Continuing..." -ForegroundColor Green
    Start-Sleep -Seconds 2
    Clear-Host
}

#Connect to vCenter if not already connected
#$currConn = Get-ViServer
#if ((Get-VM) -eq $Null) {
    try {
        Connect-ViServer -Server $vCenterServer -Credential (Get-Credential -Message "Enter your vCenter Credentials") | Out-Null
    }
    catch {
        #Make this more readable
        Write-Error -Message "Unable to connect to the specified vCenter Server. Please try again."
    }
#}
#else {
#    Write-Host "Already connect to vCenter. Continuing..."
#    Start-Sleep -Seconds 2
#    Clear-Host
#}

#Query all hosts for current NTP Settings
$currStatus = Get-VMHost |Sort-Object Name|Select-Object Name, @{N="NTPServer";E={$_ |Get-VMHostNtpServer}}, @{N="ServiceRunning";E={(Get-VmHostService -VMHost $_ | Where-Object {$_.key -eq "ntpd"}).Running}}

#If the NTP server does not comply, ask user if they want to update it
foreach ($server in $currStatus) {
    if ($server.NtpServer -eq $NtpServer) {
        $nonCompliantServers += '$server.Name + ","'
    }
}
Write-Host "The following servers do not have the requested NTP servers configured:" -ForegroundColor Red
$nonCompliantServers.split
<#
foreach ($item in $nonCompliantServers) {
    Write-Host $item    
}
#>

#Add-VMHostNtpServer -VMHost MYHost -NtpServer ‘ntp.mydomain.com‘

#If NTP Service is stopped, ask the user if they want to start it
#Get-VmHostService -VMHost MyHost | Where-Object {$_.key -eq “ntpd“} | Start-VMHostService

#Output status of service for all hosts
#Get-VMHost |Sort Name|Select Name, @{N=“NTPServer“;E={$_ |Get-VMHostNtpServer}}, @{N=“ServiceRunning“;E={(Get-VmHostService -VMHost $_ |Where-Object {$_.key-eq “ntpd“}).Running}}






