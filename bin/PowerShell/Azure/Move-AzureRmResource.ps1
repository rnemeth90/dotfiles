

#The string to search for
[Parameter(Mandatory=$true)]
[string]$SearchString,
#The source subscription
[Parameter(Mandatory=$true)]
[string]$DestinationResourceGroup,
#The destination subscription
[Parameter(Mandatory=$true)]
[string]$DestinationSubscription

$SearchString = "vcc"
$DestinationResourceGroup = "int-rg-us-nc-vcc-01"
$DestinationSubscription = "prod-expressroute-paug-01"

#login to Azure if not already connected
if ((Get-AzureRmTenant) -eq $null) {
    Login-AzureRmAccount
}

#get all Azure regions
$regions = Get-AzureRmLocation | Select-Object location

#find the objects to move
$objects = Find-AzureRmResource -ResourceNameContains $SearchString

#do some stuff with resource groups
$rgs = Get-AzureRmResourceGroup | Select-Object ResourceGroupName
if ($DestinationResourceGroup -notin $rgs) {
    $answer = Read-Host "That resource group does not exist, would you like me to create it for you? (Y or N)"
    if ($answer -eq "Y") {
        $location = Read-Host "What location should this resource group exist in? (eastus, northcentralus, etc.) "
        if ($location -notin $regions) {
            Write-Host "I do not recognize that region. Please try again using a valid region." -ForegroundColor Red
            exit
        }
        New-AzureRmResourceGroup -Name $DestinationResourceGroup -Location $location
    }
    elseif ($answer -eq "N") {
        Write-Host "Cannot continue without an existing resource group. Exiting..." -ForegroundColor Red
    }
    else {
        Write-Error "You did not enter a valid parameter. Please try again."
    }
}

#move the objects to the new subscription
foreach ($object in $objects) {
    Move-AzureRmResource -ResourceId $object.ResourceId -DestinationResourceGroupName $DestinationResourceGroup -DestinationSubscriptionId $DestinationSubscription.Id
}

