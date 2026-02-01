#!/bin/bash

# Script for deploying the entire application to Kubernetes
#
# Usage:
#   ./deploy.sh              # Deploy with current versions
#   ./deploy.sh --dry-run    # Show what will be applied (no changes)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KUSTOMIZE_DIR="$PROJECT_ROOT/kustomize"

echo "=== Deploying Orders API System ==="
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl not found. Please install kubectl."
    exit 1
fi

# Check connection to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "ERROR: No connection to Kubernetes cluster."
    echo "Run: gcloud container clusters get-credentials YOUR_CLUSTER --zone YOUR_ZONE"
    exit 1
fi

# Dry run mode
if [ "$1" == "--dry-run" ]; then
    echo "=== DRY RUN MODE ==="
    echo "The following resources will be created/updated:"
    echo ""
    kubectl kustomize "$KUSTOMIZE_DIR"
    exit 0
fi

# Create secrets (if they don't exist yet)
echo "Checking secrets..."
if ! kubectl get secret postgresql-secret -n orders-system &> /dev/null; then
    echo "Secrets not found. Creating..."
    "$SCRIPT_DIR/create-secrets.sh"
fi

# Apply configuration
echo ""
echo "Applying Kustomize configuration..."
kubectl apply -k "$KUSTOMIZE_DIR"

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Check status:"
echo "  kubectl get pods -n orders-system"
echo "  kubectl get services -n orders-system"
echo "  kubectl get ingress -n orders-system"
echo ""
echo "Logs:"
echo "  kubectl logs -f deployment/gateway -n orders-system"
echo "  kubectl logs -f deployment/orders-api-service -n orders-system"
echo "  kubectl logs -f deployment/email-sender-service -n orders-system"
echo ""
echo "Access URL:"
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
echo "  http://${INGRESS_IP}"
