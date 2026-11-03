#!/usr/bin/env bash
# Creates the starting state for ats-124-lab-020-02.
#
# 1. Applies the Task whoami.
# 2. Runs the TaskRun "before" and waits until it has succeeded. It reports uid 0,
#    because no default pod template is set yet.
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

apply_with_retry "$MANIFESTS/task-whoami.yaml"
apply_with_retry "$MANIFESTS/taskrun-before.yaml"
kubectl -n starfleet wait --for=condition=Succeeded taskrun/before --timeout=300s

echo "[lab] Starting state ready."
kubectl -n starfleet get tasks,taskruns
echo "[lab] The installation has no default pod template yet. Setting it is the task."
