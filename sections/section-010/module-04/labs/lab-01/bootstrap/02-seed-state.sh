#!/usr/bin/env bash
# Creates the starting state for ats-124-lab-010-04.
#
# Applies the Pipeline deliver in the namespace starfleet. Triggers is not installed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS="$SCRIPT_DIR/../manifests"

for attempt in $(seq 1 30); do
  kubectl apply -f "$MANIFESTS/pipeline-deliver.yaml" && break
  echo "[lab] apply failed (attempt $attempt), retrying in 5s..."
  sleep 5
done

echo "[lab] Starting state ready."
kubectl -n starfleet get pipelines
echo "[lab] Triggers is not installed yet. Installing it is the task."
