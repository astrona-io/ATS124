#!/usr/bin/env bash
# Creates the starting state for ats-124-lab-030-02.
#
# 1. Applies the Pipelines deliver and wait-forever.
# 2. Starts the PipelineRun "stuck", which holds for ten minutes.
# 3. Creates five succeeded runs of deliver, deliver-old-1 to deliver-old-5,
#    two seconds apart so that their creation times differ.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS="$SCRIPT_DIR/../manifests"

apply_with_retry() {
  # apply_with_retry FILE: the webhook can refuse the first objects while it starts.
  local attempt
  for attempt in $(seq 1 30); do
    kubectl apply -f "$1" && return 0
    echo "[lab] kubectl apply -f $1 failed (attempt $attempt), retrying in 5s..."
    sleep 5
  done
  return 1
}

apply_with_retry "$MANIFESTS/pipeline-deliver.yaml"
apply_with_retry "$MANIFESTS/pipeline-wait-forever.yaml"
apply_with_retry "$MANIFESTS/pipelinerun-stuck.yaml"

for i in 1 2 3 4 5; do
  FILE="$(mktemp)"
  cat > "$FILE" <<EOF
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: deliver-old-$i
  namespace: starfleet
spec:
  pipelineRef:
    name: deliver
  params:
    - name: target
      value: old-$i
EOF
  apply_with_retry "$FILE"
  rm -f "$FILE"
  sleep 2
done

for i in 1 2 3 4 5; do
  kubectl -n starfleet wait --for=condition=Succeeded "pipelinerun/deliver-old-$i" --timeout=300s
done

echo "[lab] Starting state ready."
kubectl -n starfleet get pipelines,pipelineruns
