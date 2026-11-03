#!/usr/bin/env bash
# Creates the alert monitors in datadog/monitors/*.json via the Datadog API
# (Monitoring as Code - alerts are version-controlled with the app).
# Usage: DD_API_KEY=<key> DD_APP_KEY=<app-key> ./scripts/create-monitors.sh
set -euo pipefail
: "${DD_API_KEY:?export DD_API_KEY}"
: "${DD_APP_KEY:?export DD_APP_KEY (Organization Settings -> Application Keys)}"
DD_SITE="${DD_SITE:-datadoghq.com}"

for file in datadog/monitors/*.json; do
  echo ">> Creating monitor from ${file}"
  curl -sS -X POST "https://api.${DD_SITE}/api/v1/monitor" \
    -H "Content-Type: application/json" \
    -H "DD-API-KEY: ${DD_API_KEY}" \
    -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
    -d @"$file" | head -c 200
  echo
done
