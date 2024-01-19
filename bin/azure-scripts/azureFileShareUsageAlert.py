from azure.identity import DefaultAzureCredential
from azure.mgmt.storage import StorageManagementClient
from math import ceil
import requests
import json

# Parameters
resource_groups = []
webhook_url = ""

# Initialize Azure credentials and StorageManagementClient
credential = DefaultAzureCredential()
storage_client = StorageManagementClient(credential, "<your-subscription-id>")

def get_storage_accounts(resource_group):
    return storage_client.storage_accounts.list_by_resource_group(resource_group)

def get_file_shares(resource_group, account_name):
    return storage_client.file_services.list_shares(resource_group_name=resource_group, account_name=account_name)

def get_share_usage_info(resource_group, account_name, share_name):
    return storage_client.file_shares.get(resource_group_name=resource_group, account_name=account_name, share_name=share_name)

for resource_group in resource_groups:
    print(f"Getting all storage accounts in resource group [{resource_group}]...")
    for storage_account in get_storage_accounts(resource_group):
        print(f"Getting all file shares in storage account [{resource_group}/{storage_account.name}]...")
        for file_share in get_file_shares(resource_group, storage_account.name):
            print(f"Getting usage info for file share [{resource_group}/{storage_account.name}/{file_share.name}]...")
            usage_info = get_share_usage_info(resource_group, storage_account.name, file_share.name)

            quota_bytes = file_share.quota * 1024 * 1024 * 1024
            usage_percentage = round((usage_info.share_usage_bytes / quota_bytes) * 100.0, 2)

            print(f"Usage info for file share [{resource_group}/{storage_account.name}/{file_share.name}]: Quota Bytes={quota_bytes}, ShareUsageBytes={usage_info.share_usage_bytes}, UsagePercentage={usage_percentage}")

            usage_data = {
                "Name": file_share.name,
                "StorageAccountName": storage_account.name,
                "ResourceGroup": resource_group,
                "QuotaBytes": quota_bytes,
                "ShareUsageBytes": usage_info.share_usage_bytes,
                "UsagePercentage": usage_percentage
            }

            if webhook_url:
                print(f"Sending data to webhook URL [{webhook_url}]")
                data_source_name = f"{resource_group}/{storage_account.name}/{file_share.name}"
                body = {
                    "Description": f"File Share - {data_source_name}",
                    "Value": usage_percentage,
                    "DataSourceName": data_source_name
                }
                response = requests.post(webhook_url, json=body, headers={"Content-Type": "application/json"})

