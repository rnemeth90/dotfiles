<#
.SYNOPSIS
Update-hcmScaleSet.ps1 - Apply an image to an existing scale set

.DESCRIPTION
This script will apply an image to an existing scale set. An Upgrade Policy should already be defined for the scale set.

.OUTPUTS
Results are only output to screen

.PARAMETER ScaleSetName
The scale set to apply the image to

.PARAMETER ImageName
The name of the image to apply

.EXAMPLE
.\Update-hcmScaleSet.ps1 -ScaleSetName myScaleSet -ImageName myImage

.NOTES
Written by: Ryan Nemeth

Find me on:

* My Blog:	http://www.geekyryan.com
* Twitter:	https://twitter.com/geeky_ryan
* LinkedIn:	https://www.linkedin.com/in/ryan-nemeth-b0b1504b/
* Github:	https://github.com/rnemeth90
* TechNet:  https://social.technet.microsoft.com/profile/ryan%20nemeth/

Change Log
V1.00, 01/12/2020 - Initial version
V1.01, 01/14/2020 - Updated help section
V1.02, 01/17/2020 - Converted 2 parameters to variables
#>


param(
    # Name of the VM to Capture
    [Parameter(Mandatory=$true)]
    [string]$ScaleSetName,

    # Name of the Image to be applied
    [Parameter(Mandatory=$true)]
    [string]$ImageName
)

$ScriptName = "Update-hcmScaleSet"
$logfile = ".\$ScriptName.log"
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


$subscriptionId="72787baf-bb18-45db-8190-887f9d6b6894"
$imageResourceGroup="images"
$vmss = Get-AzVmss -Name $ScaleSetName
$ssRg = $vmss.ResourceGroupName

Update-AzVmss `
    -ResourceGroupName $ssRg.ToString() `
    -VMScaleSetName $ScaleSetName `
    -ImageReferenceId /subscriptions/$subscriptionId/resourceGroups/$imageResourceGroup/providers/Microsoft.Compute/images/$ImageName



