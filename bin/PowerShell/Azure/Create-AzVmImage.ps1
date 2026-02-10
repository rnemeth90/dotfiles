<#
.SYNOPSIS
Create-AzVmImage.ps1 - Creates a new image from an existing virtual machine in Azure

.DESCRIPTION
This script will create a new image from an existing VM and move it to a predefined resource group

.OUTPUTS
Results are output to a text log file.

.PARAMETER SourceVmName
The source VM to create the image from

.EXAMPLE
.\Create-AzVmImage.ps1 -SourceVmName myVm -verify

.EXAMPLE
.\Create-AzVmImage.ps1 -SourceVmName myVm -prodVibeHcmDomain

.EXAMPLE
.\Create-AzVmImage.ps1 -SourceVmName myVm -prodCustomDomain

.EXAMPLE
.\Create-AzVmImage.ps1 -SourceVmName myVm

.NOTES
Written by: Ryan Nemeth

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

Change Log
V1.00, 10/21/2019 - Initial version
V1.01, 01/10/2020 - Several updates, including moving the new image to a different resource group
V1.02, 01/17/2020 - Removed several parameters and replaced with variables
V1.03, 01/11/2021 - Major overhaul/rewrite of entire script. Added error checking and improved the logic
#>

[CmdletBinding(DefaultParameterSetName='env')]
param(
    # Name of the VM to Capture
    [Parameter(Mandatory=$true)]
    [string]$SourceVmName,
    [Parameter(Mandatory=$false,parametersetname='env')]
    [switch]$verify,
    [Parameter(Mandatory=$false,parametersetname='env')]
    [switch]$prodVibeHcmDomain,
    [Parameter(Mandatory=$false,parametersetname='env')]
    [switch]$prodCustomDomain
)

# Some variables
$date = (Get-Date).ToString('MMddyyyy')
$ScriptName = "Create-AzVmImage"
$logfile = ".\$ScriptName.log"

# Create the image name
if($PSBoundParameters.ContainsKey('verify')){
    $ImageName="verify-vibehcm-webapp-"+$date+"-"+(Get-Random)
}
elseif($PSBoundParameters.ContainsKey('prodVibeHcmDomain')){
    $ImageName="production-vibehcm-webapp-"+$date+"-"+(Get-Random)
}
elseif($PSBoundParameters.ContainsKey('prodCustomDomain')){
    $ImageName="production-customDomain-webapp-"+$date+"-"+(Get-Random)
}
else{
    $ImageName= Read-Host "Please enter a name for the image"
}

# Output results to a file
function writeLog(){
    param(
        [String]$value1,
        [String]$value2,
        [String]$value3,
        [String]$value4
    )

    $date = Get-Date -DisplayHint DateTime
    [String]$date + " " + $value1 + $value2 + $value3 + $value4 | Out-File $logfile -Append
}

#Login to Azure
if (!(Get-AzContext)) {
    try {
        Login-AzAccount
    }
    catch {
        $_.ExceptionMessage
    }
}

# Get the non-azure-active-dir subscriptions
$subs = Get-AzSubscription | Where-Object name -notlike "*Active Directory*"
# Work time
foreach ($sub in $subs) {

    #Set the context to the current subscription
    Set-AzContext -SubscriptionId $sub.Id #| Out-Null
    #Find the VM
    foreach ($vm in (Get-AzVm)) {
        if ($vm.name -eq $SourceVmName) {
            $object = Get-AzResource -Id $vm.id
            $Location = $object.Location

            # ADD: Note about VM needing to be generalized before proceeding. Prompt for input value of yes or no
            $continue = Read-Host -Prompt "You must first connect to the VM and deprovision it using <# sudo waagent -deprovision for Linux, `
            or Sysprep for Windows #> BEFORE proceeding. Would you like to proceed? N to exit.(y/N)"
            if ($continue -eq 'y') {
                #Stop the Azure VM if it is not already stopped
                writeLog "Stopping the VM: $sourceVmName"
                Write-Host "Stopping the VM: $sourceVmName" -ForegroundColor Green
                Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.name -Force

                #Mark the VM as Generalized
                writeLog "Marking $sourceVmName as generalized"
                Write-Host "Marking $sourceVmName as generalized" -ForegroundColor Green
                Set-AzVm -ResourceGroupName $vm.ResourceGroupName -Name $vm.name -Generalized

                # Create VM Image context and store in var
                writeLog "Creating VM image context for VM: $sourceVmName"
                Write-Host "Creating VM image context for VM: $sourceVmName" -ForegroundColor Green
                $image = New-AzImageConfig -Location $vm.Location -SourceVirtualMachineId $vm.Id

                # Create the VM image
                # CAN WE ADD A PROGRESS BAR HERE?
                writelog "Capturing an image of VM: $sourceVmName"
                Write-Host "Capturing an image of VM: $sourceVmName" -ForegroundColor Green
                New-AzImage -Image $image -ImageName $ImageName -ResourceGroupName $vm.ResourceGroupName

                #Move the image to the images resource group
                writelog "Moving new image to images resource group: $sourceVmName"
                Write-Host "Moving new image to images resource group: $sourceVmName" -ForegroundColor Green
                $imageId = Get-AzImage -ImageName $ImageName
                Move-AzResource -DestinationResourceGroupName images -ResourceId $imageId.id -Confirm:$false
            }
            else{
                exit
            }
        }
    }
}
