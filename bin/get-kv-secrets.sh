# All config key vaults
KEY_VAULTS=(
  l17us1config-kv   # lab us1
  # l17eu2config-kv   # lab eu2
  # l17au1config-kv   # lab au1
  # p17us1config-kv   # prod us1
  # p17eu2config-kv   # prod eu2
  # p17au1config-kv   # prod au1
)

for kv in "${KEY_VAULTS[@]}"; do
  echo "=== $kv ==="
  az keyvault secret list --vault-name "$kv" \
    --query "[?contains(name, 'AssetStorageAccount')].name" \
    -o tsv 2>/dev/null
done

Or as a one-liner to show secret values too:

for kv in l17us1config-kv l17eu2config-kv l17au1config-kv p17us1config-kv p17eu2config-kv p17au1config-kv; do
  az keyvault secret list --vault-name "$kv" \
    --query "[?contains(name, 'AssetStorageAccount')].[name]" \
    -o tsv 2>/dev/null | while read name; do
      echo "[$kv] $name"
      az keyvault secret show --vault-name "$kv" -n "$name" --query value -o tsv
    done
done
