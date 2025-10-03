#!/bin/bash

SRC_SUBSCRIPTION_ID="503ee3ef-d858-4512-bc61-f7ae96e96e0a"
SRC_VAULT="prod-55us1-config01-kv"

DEST_SUBSCRIPTION_ID="3a0b2801-2ab5-4b2d-8ce7-426aa48f826f"
DEST_VAULT="prod-55us1-config03-kv"
DRY_RUN=0

az account show > /dev/null || {
  echo "Not logged in. Please run 'az login' first."
  exit 1
}

echo "Setting source subscription: $SRC_SUBSCRIPTION_ID"
az account set --subscription "$SRC_SUBSCRIPTION_ID"

echo "Getting list of secrets from source Key Vault: $SRC_VAULT"
secrets=$(az keyvault secret list --vault-name "$SRC_VAULT" --query "[].id" -o tsv)

echo "Setting destination subscription: $DEST_SUBSCRIPTION_ID"
az account set --subscription "$DEST_SUBSCRIPTION_ID"

echo "Processing secrets..."
for secret_id in $secrets; do
  secret_name=$(basename "$secret_id")

  echo "Checking if secret '$secret_name' exists in destination vault..."
  exists=$(az keyvault secret show --vault-name "$DEST_VAULT" --name "$secret_name" --query "name" -o tsv 2>/dev/null)

  if [[ "$exists" == "$secret_name" ]]; then
    echo " - Secret already exists in destination. Skipping."
  else
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "   [Dry Run] Would copy secret '$secret_name' from '$SRC_VAULT' to '$DEST_VAULT'."
      continue
    fi

    echo " - Copying secret '$secret_name'..."
    az account set --subscription "$SRC_SUBSCRIPTION_ID"
    secret_value=$(az keyvault secret show --vault-name "$SRC_VAULT" --name "$secret_name" --query "value" -o tsv)

    az account set --subscription "$DEST_SUBSCRIPTION_ID"
    az keyvault secret set --vault-name "$DEST_VAULT" --name "$secret_name" --value "$secret_value" > /dev/null

    echo "Copied successfully."
  fi
done

echo "Secret copy completed."
