#!/bin/bash

# Script for creating Kubernetes Secrets
# Run ONCE before first deployment
#
# Usage:
#   ./create-secrets.sh
#
# Or with custom passwords:
#   POSTGRES_PASSWORD=mypass MAIL_PASSWORD=mypass ./create-secrets.sh

set -e

echo "=== Creating Kubernetes Secrets ==="

# Default values (for development)
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-$(openssl rand -base64 16)}"

MAIL_HOST="${MAIL_HOST:-smtp.gmail.com}"
MAIL_PORT="${MAIL_PORT:-587}"
MAIL_USERNAME="${MAIL_USERNAME:-your-email@gmail.com}"
MAIL_PASSWORD="${MAIL_PASSWORD:-$(openssl rand -base64 16)}"

OAUTH_CLIENT_ID="${OAUTH_CLIENT_ID:-your-google-client-id}"
OAUTH_CLIENT_SECRET="${OAUTH_CLIENT_SECRET:-your-google-client-secret}"

# Create namespace if not exists
echo "Creating namespace orders-system..."
kubectl create namespace orders-system --dry-run=client -o yaml | kubectl apply -f -

# PostgreSQL Secret
echo "Creating postgresql-secret..."
kubectl create secret generic postgresql-secret \
  --from-literal=username="$POSTGRES_USER" \
  --from-literal=password="$POSTGRES_PASSWORD" \
  --namespace=orders-system \
  --dry-run=client -o yaml | kubectl apply -f -

# Email Secret
echo "Creating email-secret..."
kubectl create secret generic email-secret \
  --from-literal=host="$MAIL_HOST" \
  --from-literal=port="$MAIL_PORT" \
  --from-literal=username="$MAIL_USERNAME" \
  --from-literal=password="$MAIL_PASSWORD" \
  --namespace=orders-system \
  --dry-run=client -o yaml | kubectl apply -f -

# OAuth Secret
echo "Creating oauth-secret..."
kubectl create secret generic oauth-secret \
  --from-literal=client-id="$OAUTH_CLIENT_ID" \
  --from-literal=client-secret="$OAUTH_CLIENT_SECRET" \
  --namespace=orders-system \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "=== Secrets Created Successfully ==="
echo ""
echo "PostgreSQL:"
echo "  Username: $POSTGRES_USER"
echo "  Password: [HIDDEN]"
echo ""
echo "Email:"
echo "  Host: $MAIL_HOST"
echo "  Port: $MAIL_PORT"
echo "  Username: $MAIL_USERNAME"
echo ""
echo "OAuth:"
echo "  Client ID: $OAUTH_CLIENT_ID"
echo ""
echo "IMPORTANT: Save these credentials securely!"
echo "To view secrets: kubectl get secrets -n orders-system"
