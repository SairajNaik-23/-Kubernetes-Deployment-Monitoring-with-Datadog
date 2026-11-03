#!/usr/bin/env bash
# Installs the Datadog Agent + Cluster Agent with Helm.
# Usage: DD_API_KEY=<key> ./scripts/install-datadog.sh
set -euo pipefail
: "${DD_API_KEY:?export DD_API_KEY first}"

kubectl create namespace datadog --dry-run=client -o yaml | kubectl apply -f -

# Store the API key as a Kubernetes Secret (never in Git)
kubectl create secret generic datadog-secret -n datadog \
  --from-literal api-key="$DD_API_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

helm repo add datadog https://helm.datadoghq.com
helm repo update
helm upgrade --install datadog-agent datadog/datadog -n datadog -f datadog/values.yaml

kubectl rollout status daemonset/datadog-agent -n datadog --timeout=300s
echo ">> Datadog Agent running. Hosts appear in Datadog -> Infrastructure in 2-3 minutes."
