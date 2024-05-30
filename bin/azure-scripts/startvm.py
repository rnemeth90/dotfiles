#!/usr/bin/env python3

from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.resource import ResourceManagementClient
from argparse import ArgumentParser


if __name__ == "__main__":
    parser = ArgumentParser()

    parser.add_argument("-n","--vm_name", required=True, help="name of the vm to start")
    parser.add_argument("-r","--resource_group", required=True, help="name of the resource group containing the Azure DNS zone")
    
    args = parser.parse_args()

    vm_name = args.vm_name
    resource_group_name = args.resource_group

    # Replace these with your own values
    subscription_id = 'your_subscription_id'

    # Authenticate using DefaultAzureCredential
    credential = DefaultAzureCredential()

    # Create clients
    compute_client = ComputeManagementClient(credential, subscription_id)

    # Start the VM
    async_vm_start = compute_client.virtual_machines.begin_start(resource_group_name, vm_name)
    async_vm_start.wait()

    print(f"VM {vm_name} started.")
