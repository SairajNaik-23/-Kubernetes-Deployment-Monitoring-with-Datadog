#!/usr/bin/env bash
# Deploys the app to the current kubectl context.
# Usage: API_TOKEN=<value> ./scripts/deploy-app.sh
set -euo pipefail

kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-configmap.yaml

# Create the Secret from an env var instead of a file in Git
kubectl create secret generic demo-app-secret -n demo-app \
  --from-literal=API_TOKEN="${API_TOKEN:-change-me}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f k8s/03-deployment.yaml
kubectl apply -f k8s/04-service.yaml
kubectl apply -f k8s/05-hpa.yaml

kubectl rollout status deployment/demo-app -n demo-app --timeout=180s
kubectl get pods,svc,hpa -n demo-app
