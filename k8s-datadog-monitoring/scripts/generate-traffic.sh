#!/usr/bin/env bash
# Sends a mix of normal, slow and failing requests from inside the cluster
# so dashboards and monitors have data to show.
# Usage: ./scripts/generate-traffic.sh [requests]
set -euo pipefail
N="${1:-500}"

kubectl run traffic-gen -n demo-app --rm -i --restart=Never --image=curlimages/curl -- \
  sh -c "for i in \$(seq 1 ${N}); do
           curl -s -o /dev/null http://demo-app/;
           if [ \$((i % 10)) -eq 0 ]; then curl -s -o /dev/null http://demo-app/slow; fi;
           if [ \$((i % 15)) -eq 0 ]; then curl -s -o /dev/null http://demo-app/error; fi;
         done; echo done"
