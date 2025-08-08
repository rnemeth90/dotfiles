#!/usr/bin/env bash

# Constants for colored output
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'

# Logging helpers
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }

NAMESPACE=""
INIT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --init)
      INIT=true
      shift
      ;;
    init|true)
      INIT=true
      shift
      ;;
    -*)
      log_error "Unknown option: $1"
      exit 1
      ;;
    *)
      if [[ -z "$NAMESPACE" ]]; then
        NAMESPACE="$1"
      else
        log_warn "Ignoring extra argument: $1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$NAMESPACE" ]]; then
  log_error "Usage: $0 <namespace> [--init|init|true]"
  exit 1
fi

log_info "Using namespace: $NAMESPACE"

HOSTNAME="us1-$(echo "$NAMESPACE" | cut -d'-' -f2).labs.aprimo.com"
log_info "Computed hostname: $HOSTNAME"

for cmd in ktunnel kubectl az kubelogin; do
  if ! command -v "$cmd" &> /dev/null; then
    log_error "$cmd is not installed or not on PATH. Please install it and try again."
    exit 1
  else
    log_success "$cmd is installed"
  fi
done

if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
  log_error "Namespace '$NAMESPACE' does not exist. Please create the namespace and try again."
  exit 1
fi
log_success "Namespace '$NAMESPACE' exists"

log_info "Setting kubectl context to namespace '$NAMESPACE'"
kubectl config set-context --current --namespace="$NAMESPACE"

if [[ "$INIT" == "true" ]]; then
  log_info "Running initialization tasks..."

  INGRESS_NAME="cip-ingress"
  log_info "Applying ingress: $INGRESS_NAME"

  cat <<EOF | kubectl apply -f - &> /dev/null \
    && log_success "Ingress created" \
    || log_error "Failed to create ingress"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTP
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
  name: $INGRESS_NAME
  namespace: $NAMESPACE
spec:
  ingressClassName: nginx-ingress-pub-pm-r09
  rules:
  - host: $HOSTNAME
    http:
      paths:
      - path: /ci/control
        pathType: Prefix
        backend:
          service:
            name: pxpcontrollocal
            port:
              number: 8080
      - path: /ci/ui
        pathType: Prefix
        backend:
          service:
            name: pxpdashboardlocal
            port:
              number: 8081
      - path: /ci/data
        pathType: Prefix
        backend:
          service:
            name: pxpdatalocal
            port:
              number: 8082
      - path: /ci
        pathType: Prefix
        backend:
          service:
            name: pxprealtimelocal
            port:
              number: 8083
EOF

else
  log_info "Skipping initialization tasks as INIT is set to false."
fi

log_info "Exposing services with ktunnel..."
declare -a SERVICES=(
  "pxpcontrollocal 8080"
  "pxpdashboardlocal 8081"
  "pxpdatalocal 8082"
  "pxprealtimelocal 8083"
)

for entry in "${SERVICES[@]}"; do
  svc=$(echo "$entry" | awk '{print $1}')
  port=$(echo "$entry" | awk '{print $2}')
  log_info "Exposing $svc on port $port..."

  (
    if ktunnel expose -n "$NAMESPACE" -q kubernetes.io/os=linux "$svc" "$port:$port" &> /dev/null; then
      log_success "$svc exposed on port $port"
    else
      log_warn "Failed to expose $svc on port $port"
    fi
  ) &
  log_info "$svc PID: $!"
done
