using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

if ($ENV:MSI_SECRET -and (Get-Module -ListAvailable Az.Accounts)){
    Connect-AzAccount -Identity
}

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$scaleSets = @(
    "prodssusnchcm01",
    "prodssusnchcm03"
    "verssusnchcm01"
)

foreach ($VmssName in $scaleSets) {
    $ResourceGroupName = (Get-AzResource -Name $VmssName).ResourceGroupName
    $instances = Get-AzVmssVM -ResourceGroupName $ResourceGroupName -VMScaleSetName $VmssName
    $ssNicName = ($instances[0].NetworkProfile.NetworkInterfaces[0].Id).Split('/')[-1]

    foreach ($instance in $instances)
    {
        $resourceName = $vmssName + "/" + $instance.InstanceId + "/" + $ssNicName
        $target = Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Compute/virtualMachineScaleSets/virtualMachines/networkInterfaces -ResourceName $resourceName -ApiVersion 2017-12-01
        $tags =(Get-AzResource -ResourceName $vmssname -ResourceGroupName $ResourceGroupName).tags
        [array]$result += @{Service=$tags.service;Server=($instance.Name);IP=($target.Properties.ipConfigurations[0].properties.privateIPAddress)}
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $($result | ConvertTo-Json)
})
