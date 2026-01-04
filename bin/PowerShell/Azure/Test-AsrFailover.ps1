<#
.SYNOPSIS
Test-AsrFailover.ps1 - Tests failover of VMs using Azure Site Recovery

.DESCRIPTION
This script will connect to vCenter and power down (hard-shutdown) virtual machines.
It will then connect to your Azure tenant, gather info about a Recovery Services Vault,
and then perform a test failover of the specified virtual machines. It will also assign public
IP addresses to the NICs and then copy the newly assigned public IPs and name of the VMs into a
hash table. At the end of the script, the hash table will be output to the console so that you can
update any necessary DNS records.

.OUTPUTS
#Logs to be added later

.EXAMPLE

.NOTES
Written by: Ryan Nemeth

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

Change Log
V1.10.08222018, 08/22/2018 - Initial version
V1.11.08232018, 08/23/2018 - Fixed bugs with public IP address provisioning
V1.12.08232018, 08/23/2018 - Added code for updating DNS records
V1.13.08202020, 08/20/2020 - Adding check for vSphere PowerCLI module
V1.14.09162020, 08/20/2020 - Adding functionality for updating Azure DNS

#>

####################################################
#TO DO:
# Add logging to file - DONE
# Add error handling - KINDA DONE
# Add ability to update DNS Records in Azure DNS - DONE (needs to be re-architected)
# Add ability to update internal DNS
# Add ability to cleanup resources in Site Recovery after test is complete

# ----------------------------------------------------------------------------

#THIS DOES NOT WORK YET
param(
    # Name of the VM to Capture
    [Parameter(Mandatory=$false)]
    [string]$Status
)

#### Check if transcript already exists, if so remove
if (Test-Path -Path $env:SystemDrive\Test-AsrFailover.log) {
    $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
    Rename-Item -Path "$env:SystemDrive\Test-AsrFailover.log" -NewName "Test-AsrFailover.log.$timestamp"
}

Start-Transcript -Path $env:SystemDrive\Test-AsrFailover.log


# UPDATE SERVERS AND URLS HERE:
$reports = "drosreports"
$vibepay = "drvibepay"
$vmlist = @(
    "sbdvpwt10",
    "sbdrptt10",
    "sbdpayt10",
    "sbdsqlt01"
)


#################################################################
########## DO NOT CHANGE ANYTHING BEYOND THIS POINT #############
#################################################################


#var
$dnsRg = "prod-rg-us-nc-dns-03"
$dnsZone = "vibehcm.com"
$dnsRecordType = "A"
$cred = Get-Credential -Message "Please type in your Azure tenant/VMware credentials. Creds must be identical (dirsync'd)"
$asrSubscriptionId = "5e4bfeb2-2d37-4e4e-aa0c-5ab41fe19b2a"
$vnetSubscriptionId = "*72787baf-bb18-45db-8190-887f9d6b6894*"
$vaultName = "int-rsv-us-nc-asr-01"
$vaultResourceGroup = "int-rg-us-nc-asr-01"
$failoverVnet = "prod-vn-us-nc-vnet-01"
$failoverVnetRg = "prod-rg-us-nc-net-01"
$vcenterServer = "sbdvisp01.corp.vibehcm.com"



function ConnectToAzure {
    #Connect to Azure and set context
    Write-host "Connecting to Azure and gathering info..." -ForeGroundColor Green
    Connect-AzAccount -credential $cred | Out-Null
    Select-AzSubscription -subscriptionId $asrSubscriptionId | Out-Null
    $vnetSubscriptionContext = get-azcontext -ListAvailable | Where-Object Name -like $vnetSubscriptionId
    $vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultResourceGroup
    Set-AzRecoveryServicesAsrVaultContext -vault $vault | Out-Null
    $ASRFabrics = Get-AzRecoveryServicesAsrFabric
}


# THIS DOES NOT WORK YET
function checkJobStatus() {
    param (
        [string]$object
    )

    ConnectToAzure
    $vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultResourceGroup
    Set-AzRecoveryServicesAsrVaultContext -vault $vault | Out-Null
    Get-AzRecoveryServicesAsrJob -TargetObjectId $object
}

function Check-LoadedModule() {
    Param(
        [parameter(Mandatory = $true)][alias("Module")]
        [string]$ModuleName
    )
    $LoadedModules = Get-Module | Select-Object Name
    if (!$LoadedModules -like "*$ModuleName*"){
        Write-Host "Importing the $ModuleName PowerShell module" -ForegroundColor Yellow
        try {
            Import-Module -Name $ModuleName
        }
        catch {
            Write-Host "Could not load the $ModuleName module. Please ensure it is installed." -ForegroundColor Red
        }
    }
}



#Check if VMware PowerCLI is installed
Clear-Host
Write-Host "Checking if VMware PowerCLI is loaded..." -ForegroundColor Green
Check-LoadedModule -ModuleName "VMware.VimAutomation.Core"

#Connect to VMware and power off VMs
try {
    Write-host "Connecting to $vcenterServer..." -ForeGroundColor Green
    Connect-ViServer -Server $vcenterServer -credential $cred | Out-Null
}
catch {
    Write-Host "Cannot connect to vCenter. Ensure you are using the vCenter FQDN,
    DNS is working, and your credentials are correct." -ForegroundColor Red
}

if ($Status) {
    foreach ($vm in $vmlist) {
        checkJobStatus($vm)
        Exit
    }
}

foreach($vm in $vmlist){
    Write-host "Stopping:" ($vm).toUpper() -ForeGroundColor Yellow
    try {
        Stop-Vm -VM $vm -kill -Confirm:$false | Out-Null
    }
    catch {
        Write-Host "Cannot stop ($vm).toUpper(). Power it off manually in vCenter before proceeding." -ForegroundColor Red
    }
}


Write-host "Sleeping for 15 seconds..." -ForeGroundColor Green
Start-Sleep -s 15

ConnectToAzure

#Start the failover process
Write-Host "Starting failover process..." -ForeGroundColor Yellow

$vnetSubscriptionContext = get-azcontext -ListAvailable | Where-Object Name -like $vnetSubscriptionId
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultResourceGroup
Set-AzRecoveryServicesAsrVaultContext -vault $vault | Out-Null
$ASRFabrics = Get-AzRecoveryServicesAsrFabric
$ProtectionContainer = Get-ASRProtectionContainer -Fabric $ASRFabrics[0]
$TestFailovervnet = Get-AzVirtualNetwork -Name $failoverVnet -ResourceGroupName $failoverVnetRg -DefaultProfile $vnetSubscriptionContext[0]
foreach($vm in $vmlist){
    $ReplicatedVM = Get-AzRecoveryServicesAsrReplicationProtectedItem -FriendlyName $vm -ProtectionContainer $ProtectionContainer
    $RecoveryPoints = Get-ASRRecoveryPoint -ReplicationProtectedItem $ReplicatedVM
    Write-host "Starting failover test for:" ($vm).toUpper()  -ForeGroundColor Yellow
    $TFOJob = Start-AzRecoveryServicesAsrTestFailoverJob -ReplicationProtectedItem $ReplicatedVm -AzureVMNetworkId $TestFailovervnet.Id -Direction PrimaryToRecovery -RecoveryPoint $RecoveryPoints[-1]

    do {
        $TFOJobStatus = Get-ASRJob -Job $TFOJob;
        Start-Sleep 30;
    } while (($TFOJobStatus.State -eq "InProgress") -or ($TFOJobStatus.State -eq "NotStarted"))
}


#Assign Public IP addresses to replicated VMs

$dnslist = @{}

# REPORT AND SQL SERVERS DO NOT NEED PUBLIC IPs
foreach($vm in $vmlist){
    Write-host "Assigning Public IP to:" ($vm).toUpper() -ForeGroundColor Yellow
    $azurevm = Get-AzVM -ResourceGroupName $vaultResourceGroup -Name $vm"-test" -DefaultProfile $vnetSubscriptionContext[0] -ErrorAction Ignore -WarningAction Ignore -InformationAction Ignore
    $VMNetworkInterfaceObject = Get-AzResource -ResourceId $azurevm.NetworkProfile.NetworkInterfaces[0].Id | Get-AzNetworkInterface -DefaultProfile $vnetSubscriptionContext[0]
    $pip = New-AzPublicIpAddress -Name $azurevm.Name -ResourceGroupName $azurevm.ResourceGroupName -Location $azurevm.Location -AllocationMethod Static -Force -DefaultProfile $vnetSubscriptionContext[0]
    If($pip -ne $Null) {
        $VMNetworkInterfaceObject.IpConfigurations[0].PublicIpAddress = $PIP
    }
    #Update the properties now
    Set-AzNetworkInterface -NetworkInterface $VMNetworkInterfaceObject -DefaultProfile $vnetSubscriptionContext[0] | out-null

    #add PIP and name to hash table
    $dnslist.add($vm,$pip.IpAddress)
}

Write-host "Sleeping for 15 seconds" -ForeGroundColor Green
Start-Sleep -s 15

#Updating DNS Records
Write-Host "Updating external DNS Records..." -ForegroundColor Yellow
Set-AzContext -SubscriptionId 72787baf-bb18-45db-8190-887f9d6b6894 | Out-Null
$dnsKeys = $dnslist.Keys

#this is messy and I don't like it. Need to recreate.
foreach ($item in $dnsKeys) {
    if($dnsKeys -like "*rpt*"){
        $hostname = "sbdrptt10"
        $vm = Get-AzVm -Name "sbdrptt10-test" -ResourceGroupName int-rg-us-nc-asr-01
        $publicIp = $dnslist["sbdrptt10"]
        $iface = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].id | Get-AzNetworkInterface
        $privateIp = $iface.IpConfigurations[0].PrivateIpAddress

        Write-Host "Updating $reports.$dnsZone" -ForegroundColor Yellow
        $RecordSet = Get-AzDnsRecordSet -ResourceGroupName $dnsRg -ZoneName $dnsZone -Name $reports -RecordType $dnsRecordType
        $RecordSet.Records[0].Ipv4Address = $dnslist["sbdrptt10"]
        Set-AzDnsRecordSet -RecordSet $RecordSet | Out-Null
        Write-Host $hostname " = " $privateIp -ForegroundColor Green
        Write-Host "drosreports.vibehcm.com = " $publicIp -ForeGroundColor Green
    }
    elseif($dnsKeys -like "*vpw*"){
        $hostname = "sbdvpwt10"
        $vm = Get-AzVm -Name "sbdvpwt10-test" -ResourceGroupName int-rg-us-nc-asr-01
        $publicIp = $dnslist["sbdvpwt10"]
        $iface = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].id | Get-AzNetworkInterface
        $privateIp = $iface.IpConfigurations[0].PrivateIpAddress

        Write-Host "Updating $vibepay.$dnsZone" -ForegroundColor Yellow
        $RecordSet = Get-AzDnsRecordSet -ResourceGroupName $dnsRg -ZoneName $dnsZone -Name $vibepay -RecordType $dnsRecordType
        $RecordSet.Records[0].Ipv4Address = $dnslist["sbdvpwt10"]
        Set-AzDnsRecordSet -RecordSet $RecordSet | Out-null
        Write-Host $hostname " = " $privateIp -ForegroundColor Green
        Write-Host "drvibepay.vibehcm.com = " $publicIp -ForeGroundColor Green
    }
    else{
        Write-Error "Unable to Set DNS record for $item. Please update it manually."
    }
}

Stop-Transcript


