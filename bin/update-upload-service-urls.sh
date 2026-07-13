#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "*** DRY RUN — no changes will be made ***"
  echo ""
fi

TABLE_NAME="aprimoconfig"

echo "Querying tenants with .dam. in uploadServiceUrl..."

TENANTS=$(az storage entity query \
  --table-name "$TABLE_NAME" \
  --filter "RowKey eq 'pmUrl' or RowKey eq 'uploadServiceUrl'" \
  --connection-string "$CONNECTION_STRING" \
  --output json | jq -r '
    .items
    | group_by(.PartitionKey)
    | map({
        tenant: .[0].PartitionKey,
        pmUrl: (map(select(.RowKey == "pmUrl")) | first | .Value // ""),
        uploadServiceUrl: (map(select(.RowKey == "uploadServiceUrl")) | first | .Value // "")
      })
    | map(select(.pmUrl != "" and ((.uploadServiceUrl | contains(".dam.")) or (.uploadServiceUrl | endswith("/")))))
    | .[]
    | "\(.tenant)|\(.uploadServiceUrl)"
  ')

COUNT=0
while IFS="|" read -r PARTITION_KEY OLD_URL; do
  [[ -z "$PARTITION_KEY" ]] && continue
  NEW_URL=$(echo "$OLD_URL" | sed 's/\.dam\./\./' | sed 's|/*$||')

  echo "Updating $PARTITION_KEY: $OLD_URL -> $NEW_URL"

  if [ "$DRY_RUN" = false ]; then
    az storage entity merge \
      --table-name "$TABLE_NAME" \
      --connection-string "$CONNECTION_STRING" \
      --entity "PartitionKey=$PARTITION_KEY" "RowKey=uploadServiceUrl" "Value=$NEW_URL" \
      --output none
    echo "  ✓ Done"
  else
    echo "  [dry-run] skipped"
  fi
  COUNT=$((COUNT + 1))
done <<< "$TENANTS"

echo ""
echo "Updated $COUNT tenant(s)."
