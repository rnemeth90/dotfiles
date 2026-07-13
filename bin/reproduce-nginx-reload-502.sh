#!/usr/bin/env bash
# reproduce-nginx-reload-502.sh
#
# Reproduces 502s caused by nginx-ingress reloading on endpoint churn.
# Creates a test deployment in a specified namespace behind the F5 nginx-ingress,
# then rapidly scales it to drive reloads while hammering the upstream with requests.
#
# Usage:
#   reproduce-nginx-reload-502.sh <namespace> <ingress-class> <test-host> [--cleanup]
#
# Examples:
#   reproduce-nginx-reload-502.sh dam-c310 prod-internal-nginx-dam-c310 test.dam.aprimo.com
#   reproduce-nginx-reload-502.sh dam-c310 prod-internal-nginx-dam-c310 test.dam.aprimo.com --cleanup
#
# Requirements: kubectl, curl (wrk optional for load generation)

set -euo pipefail

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }

NAMESPACE="${1:-}"
INGRESS_CLASS="${2:-}"
TEST_HOST="${3:-}"
CLEANUP=false

for arg in "$@"; do
  [[ "$arg" == "--cleanup" ]] && CLEANUP=true
done

if [[ -z "$NAMESPACE" || -z "$INGRESS_CLASS" || -z "$TEST_HOST" ]]; then
  log_error "Usage: $0 <namespace> <ingress-class> <test-host> [--cleanup]"
  exit 1
fi

DEPLOY_NAME="nginx-reload-502-test"
SVC_NAME="nginx-reload-502-test"
INGRESS_NAME="nginx-reload-502-test"
METRICS_PORT=19113

cleanup() {
  log_info "Cleaning up test resources..."
  kubectl delete deployment "$DEPLOY_NAME" -n "$NAMESPACE" --ignore-not-found
  kubectl delete service "$SVC_NAME" -n "$NAMESPACE" --ignore-not-found
  kubectl delete ingress "$INGRESS_NAME" -n "$NAMESPACE" --ignore-not-found
  log_success "Cleanup complete"
}

if $CLEANUP; then
  cleanup
  exit 0
fi

# --- Trap to clean up on exit ---
trap cleanup EXIT

# --- Get a metrics pod to track reloads ---
METRICS_POD=$(kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=${INGRESS_CLASS}" \
  -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

if [[ -z "$METRICS_POD" ]]; then
  log_warn "Could not find nginx-ingress pod for class $INGRESS_CLASS — reload tracking disabled"
fi

# --- Create test deployment (nginx:alpine as a trivial HTTP server) ---
log_info "Creating test deployment: $DEPLOY_NAME"
kubectl apply -n "$NAMESPACE" -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOY_NAME
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $DEPLOY_NAME
  template:
    metadata:
      labels:
        app: $DEPLOY_NAME
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 10m
            memory: 16Mi
EOF

kubectl apply -n "$NAMESPACE" -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: $SVC_NAME
  namespace: $NAMESPACE
spec:
  selector:
    app: $DEPLOY_NAME
  ports:
  - port: 80
    targetPort: 80
EOF

kubectl apply -n "$NAMESPACE" -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $INGRESS_NAME
  namespace: $NAMESPACE
  annotations:
    nginx.org/proxy-read-timeout: "30"
spec:
  ingressClassName: $INGRESS_CLASS
  rules:
  - host: $TEST_HOST
    http:
      paths:
      - path: /nginx-reload-test
        pathType: Prefix
        backend:
          service:
            name: $SVC_NAME
            port:
              number: 80
EOF

log_info "Waiting for deployment to be ready..."
kubectl rollout status deployment/"$DEPLOY_NAME" -n "$NAMESPACE" --timeout=60s

# --- Start reload counter tracking ---
RELOAD_LOG=/tmp/nginx-reload-502-reloads.log
echo "timestamp,reload_total" > "$RELOAD_LOG"

track_reloads() {
  local pod="$1"
  local last=0
  log_info "Tracking nginx reloads on pod $pod → $RELOAD_LOG"
  kubectl port-forward -n "$NAMESPACE" "$pod" ${METRICS_PORT}:9113 > /tmp/pf-reload.log 2>&1 &
  local pf_pid=$!
  sleep 2
  while true; do
    local count
    count=$(curl -s "http://localhost:${METRICS_PORT}/metrics" 2>/dev/null \
      | grep 'nginx_reloads_total{.*reason="endpoints"' \
      | awk '{print $2}' | cut -d. -f1 || echo "")
    if [[ -n "$count" ]] && [[ "$count" -gt "$last" ]] 2>/dev/null; then
      local ts
      ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
      echo "$ts,$count" | tee -a "$RELOAD_LOG"
      last="$count"
    fi
    sleep 1
  done
  kill $pf_pid 2>/dev/null || true
}

if [[ -n "$METRICS_POD" ]]; then
  track_reloads "$METRICS_POD" &
  TRACKER_PID=$!
fi

# --- Send continuous requests while churning endpoints ---
REQUEST_LOG=/tmp/nginx-reload-502-requests.log
echo "timestamp,http_status,time_total" > "$REQUEST_LOG"

send_requests() {
  log_info "Sending continuous requests to https://${TEST_HOST}/nginx-reload-test → $REQUEST_LOG"
  while true; do
    local ts http_code time_total
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    read -r http_code time_total < <(
      curl -sk -o /dev/null \
        -w "%{http_code} %{time_total}" \
        --max-time 5 \
        -H "Host: ${TEST_HOST}" \
        "https://${TEST_HOST}/nginx-reload-test" 2>/dev/null || echo "000 0"
    )
    echo "$ts,$http_code,$time_total" | tee -a "$REQUEST_LOG"
    [[ "$http_code" == "502" ]] && log_warn "502 at $ts (${time_total}s)"
    sleep 0.5
  done
}

send_requests &
REQ_PID=$!

# --- Churn endpoints: scale up/down repeatedly ---
log_info "Starting endpoint churn (scale 1→20→1, 10 cycles)..."
for i in $(seq 1 10); do
  log_info "Cycle $i: scaling up to 20..."
  kubectl scale deployment "$DEPLOY_NAME" -n "$NAMESPACE" --replicas=20
  sleep 5

  log_info "Cycle $i: scaling down to 1..."
  kubectl scale deployment "$DEPLOY_NAME" -n "$NAMESPACE" --replicas=1
  sleep 5
done

log_info "Churn complete. Letting requests run for 15 more seconds..."
sleep 15

kill $REQ_PID 2>/dev/null || true
[[ -n "${TRACKER_PID:-}" ]] && kill $TRACKER_PID 2>/dev/null || true

# --- Summary ---
echo ""
log_info "=== Results ==="
TOTAL=$(tail -n +2 "$REQUEST_LOG" | wc -l | tr -d ' ')
FIVES=$(grep ",502," "$REQUEST_LOG" | wc -l | tr -d ' ')
log_info "Total requests:  $TOTAL"
[[ "$FIVES" -gt 0 ]] && log_error "502s observed:   $FIVES" || log_success "502s observed:   0"
log_info "Request log:     $REQUEST_LOG"
log_info "Reload log:      $RELOAD_LOG"

echo ""
log_info "To correlate: check ADX nginxAccessLogs for the timestamps in $RELOAD_LOG"
log_info "ADX query:"
echo "  nginxAccessLogs"
echo "  | where time_iso8601 between (datetime(FIRST_RELOAD) .. datetime(LAST_RELOAD))"
echo "  | where status == 502"
echo "  | where aprimo_upstream_name has \"nginx-reload-502-test\""

trap - EXIT
cleanup
