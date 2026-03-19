#!/usr/bin/env bash
set -euo pipefail

#######################################
# Defaults
#######################################
INGRESS_CLASS="nginx-ingress-pub-dam-c900"
# INGRESS_CLASS="nginx-ingress-pub-pm-r09"
TTL=300
DRY_RUN=false
PARALLEL=5

#######################################
# Usage
#######################################
usage() {
  cat <<EOF
Usage:
  $0 --dns-zone ZONE --resource-group RG [options]

Required:
  --dns-zone            Azure DNS zone (e.g. labs.aprimo.com)
  --resource-group      Azure DNS resource group

Optional:
  --ingress-class       Ingress class (default: ${INGRESS_CLASS})
  --ttl                 DNS TTL (default: ${TTL})
  --parallel            Parallel workers (default: ${PARALLEL})
  --dry-run             Print changes only
  --help                Show help
EOF
  exit 1
}

#######################################
# Parse Args
#######################################
DNS_ZONE=""
RESOURCE_GROUP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dns-zone) DNS_ZONE="$2"; shift 2 ;;
    --resource-group) RESOURCE_GROUP="$2"; shift 2 ;;
    --ingress-class) INGRESS_CLASS="$2"; shift 2 ;;
    --ttl) TTL="$2"; shift 2 ;;
    --parallel) PARALLEL="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help) usage ;;
    *) echo "Unknown arg: $1"; usage ;;
  esac
done

[[ -z "$DNS_ZONE" || -z "$RESOURCE_GROUP" ]] && usage

#######################################
# Sync Function
#######################################
sync_record() {
  local fqdn="$1"
  local ip="$2"

  record_name="${fqdn%.$DNS_ZONE}"

  # Fetch current IPs
  current_ips=$(az network dns record-set a show \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DNS_ZONE" \
    --name "$record_name" \
    --query "aRecords[].ipv4Address" \
    -o tsv 2>/dev/null || true)

  # Drift detection
  if echo "$current_ips" | grep -qx "$ip"; then
    echo "✓ Skipping $record_name (already $ip)"
    return
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[DRY-RUN] Would update $record_name -> $ip"
    return
  fi

  echo "Updating $record_name -> $ip"

  # Ensure record exists
  az network dns record-set a create \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DNS_ZONE" \
    --name "$record_name" \
    --ttl "$TTL" \
    --output none 2>/dev/null || true

  # Remove old IPs
  for old_ip in $current_ips; do
    az network dns record-set a remove-record \
      --resource-group "$RESOURCE_GROUP" \
      --zone-name "$DNS_ZONE" \
      --record-set-name "$record_name" \
      --ipv4-address "$old_ip" \
      --output none || true
  done

  # Add new IP
  az network dns record-set a add-record \
    --resource-group "$RESOURCE_GROUP" \
    --zone-name "$DNS_ZONE" \
    --record-set-name "$record_name" \
    --ipv4-address "$ip" \
    --output none
}

export -f sync_record
export DNS_ZONE RESOURCE_GROUP TTL DRY_RUN

#######################################
# Main
#######################################
echo "Ingress class: $INGRESS_CLASS"
echo "DNS Zone:      $DNS_ZONE"
echo "Resource Group:$RESOURCE_GROUP"
echo "Parallel:      $PARALLEL"
echo "Dry Run:       $DRY_RUN"
echo

kubectl get ing -A -o json \
| jq -r --arg CLASS "$INGRESS_CLASS" '
  .items[]
  | select(.spec.ingressClassName == $CLASS)
  | select(.status.loadBalancer.ingress != null)
  | . as $ing
  | $ing.status.loadBalancer.ingress[].ip as $ip
  | $ing.spec.rules[].host
  | "\(. )|\($ip)"
' \
| sort -u \
| xargs -P "$PARALLEL" -n 1 -I {} bash -c '
    IFS="|" read -r host ip <<< "{}"
    sync_record "$host" "$ip"
'

echo
echo "Done."

