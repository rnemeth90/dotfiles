# Get subscriptions and loop through them
$subscriptions = Get-AzSubscription

# empty array to store the objects we collect
$results = New-Object System.Collections.ArrayList

foreach ($subscription in $Subscriptions) {

    #Get all resource groups in the subscription
    $resourceGroups = Get-AzResourceGroup

    #Loop through all resource groups in the subscription and get the deployment date
    foreach ($resourceGroup in $resourceGroups) {

        #Find all deployments for the resource group over the last week
        $deployments = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup.ResourceGroupName
        foreach ($deployment in $deployments) {
            if ($deployment.Timestamp -gt (Get-Date).AddDays(-7)) {

                    $resources = Get-AzResource -ResourceGroupName $deployment.ResourceGroupName
                    #try and get the cost of the resource
                    $costObject = $null
                    $cost = $null
                    $parent = $null

                    foreach ($resource in $resources) {
                        $CostObject = Get-AzConsumptionUsageDetail -InstanceName $resource.Name -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) `
                        | Sort-Object -Property UsageQuantity -Descending `
                        | Select-Object -First 1

                        If($costObject){
                           $cost = ($CostObject.PretaxCost | Measure-Object -Sum).Sum
                        } else {
                        }

                        $results.Add((New-Object -TypeName PSObject -property @{
                            "Resource"=$resource.Name;
                            "Cost"=$cost;
                            "CreationDate"=$deployment.TimeStamp;
                            #"CreatedBy"=$resource.tags
                            #"DeploymentName"=$deployment.DeploymentName;
                            #"ResourceGroupName"=$deployment.ResourceGroupName;
                            #"TimeStamp"=$deployment.Timestamp;
                            #"DeploymentMode"=$deployment.Mode;
                        })) | Out-Null
                    }
            }
        }
    }
}

$results

