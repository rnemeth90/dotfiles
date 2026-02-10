<#
    .SYNOPSIS
     Queries a given storage account resource type (container, table, queue, share) for various statistics.
     This script is primarily focused on reporting consumption size of the resource and the LastModifiedDate
    .PARAMETER StorageAccountName
     Name of the storage account
    .PARAMETER ResourceGroupName
     Name of the resource group containing the storage account
    .PARAMETER Type
     The type of storage resource to query. Can be 'Containers', 'Queues', 'Shares', or 'Tables'
    .EXAMPLE
     Get-AzStorageStatistics -StorageAccountName ContosoStorage -ResourceGroupName ContosoResources -Type Containers
    .EXAMPLE
     Get-AzStorageStatistics -StorageAccountName ContosoStorage -ResourceGroupName ContosoResources -Type Queues
    .EXAMPLE
     Get-AzStorageStatistics -StorageAccountName ContosoStorage -ResourceGroupName ContosoResources -Type Shares
    .EXAMPLE
     Get-AzStorageStatistics -StorageAccountName ContosoStorage -ResourceGroupName ContosoResources -Type Tables
    .NOTES
     Author: Ryan Nemeth - RyanNemeth@live.com
     Site: http://www.geekyryan.com
    .LINK
     http://www.geekyryan.com
    .DESCRIPTION
     Version 1.0
#>

using namespace Microsoft.Azure.Commands.Common.Authentication.Abstractions
using namespace Microsoft.WindowsAzure.Commands.Common.Storage.ResourceModel
using namespace Microsoft.WindowsAzure.Commands.Common.Storage
#Requires -Modules AzTable,Az.Resources,Az.Storage

function Get-AzStorageStatistics {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Containers", "Shares", "Queues", "Tables")]
        [string]$Type
    )

    begin { }

    process {
        # Get the storage account
        $storageAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName
        $context = $storageAccount.context

        switch ($Type) {
            "Containers" {
                Get-AzStorageContainerStatistics -StorageContext $context
            }
            "Shares" {
                Get-AzStorageShareStatistics -StorageContext $context
            }
            "Queues" {
                Get-AzStorageQueueStatistics -StorageContext $context
            }
            "Tables" {
                Get-AzStorageTableStatistics -StorageContext $context
            }
            Default {}
        }
    }

    end { }
}

function Get-AzStorageContainerStatistics {
    param (
        [Parameter(Mandatory = $true)]
        [IStorageContext]$StorageContext
    )

    $results = @()
    $containers = Get-AzStorageContainer -Context $StorageContext
    foreach ($c in $containers) {
        #What should we return for containers
        # name, size, public access, lastModified
        $size = 0
        $blobs = Get-AzStorageBlob -Container $c.Name -ErrorAction SilentlyContinue
        $blobs | ForEach-Object { $size = $size + $_.Length }

        $details = [PSCustomObject]@{
            ContainerName = $c.Name
            PublicAccess  = $c.PublicAccess
            LastModified  = $c.BlobContainerProperties.LastModified
            Size          = $size
        }
        $results += $details
    }
    return $results
}

function Get-AzStorageShareStatistics {
    param (
        [Parameter(Mandatory = $true)]
        [IStorageContext]$StorageContext
    )

    $results = @()
    $shares = Get-AzStorageShare -Context $StorageContext
    foreach ($s in $shares) {

        $bytes = $s.ShareClient.GetStatistics().Value.ShareUsageInBytes

        $details = [PSCustomObject]@{
            ShareName    = $s.Name
            LastModified = $s.ShareProperties.LastModified
            SizeInBytes  = $bytes
        }
        $results += $details
    }
    return $results
}

function Get-AzStorageQueueStatistics {
    param (
        [Parameter(Mandatory = $true)]
        [IStorageContext]$StorageContext
    )

    $results = @()
    $queues = Get-AzStorageQueue -Context $StorageContext

    foreach ($q in $queues) {
        $details = [PSCustomObject]@{
            QueueName               = $q.Name
            ApproximateMessageCount = $q.ApproximateMessageCount
        }
        $results += $details
    }
    return $results
}

function Get-AzStorageTableStatistics {
    param (
        [Parameter(Mandatory = $true)]
        [IStorageContext]$StorageContext
    )

    $results = @()
    $tables = Get-AzStorageTable -Context $StorageContext

    foreach ($t in $tables) {
        $rowCount = (Get-AzTableRow -Table $t.CloudTable | Measure-Object).Count
        $details = [PSCustomObject]@{
            TableName = $t.Name
            RowCount  = $rowCount
        }
        $results += $details
    }
    return $results
}