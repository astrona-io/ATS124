#!/usr/bin/env bash
# Creates the starting state for ats-124-lab-030-01.
#
# 1. Applies the Task hello in starfleet (the right one).
# 2. Applies a decoy Task hello in default, and one stray TaskRun of it.
#
# Running the right Task with tkn and cleaning up default is the task.
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

wait_for_taskrun_end() {
  # wait_for_taskrun_end NAMESPACE NAME: waits until Succeeded is True or False.
  local status=""
  for _ in $(seq 1 60); do
    status="$(kubectl -n "$1" get taskrun "$2" \
      -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}' 2>/dev/null || true)"
    if [ "$status" = "True" ] || [ "$status" = "False" ]; then
      echo "[lab] TaskRun $1/$2 ended with Succeeded=$status."
      return 0
    fi
    sleep 3
  done
  echo "ERROR: TaskRun $1/$2 did not end in time." >&2
  return 1
}

apply_with_retry "$MANIFESTS/task-hello-starfleet.yaml"
apply_with_retry "$MANIFESTS/task-hello-default.yaml"
apply_with_retry "$MANIFESTS/taskrun-hello-default.yaml"
wait_for_taskrun_end default hello-run-stray

echo "[lab] Starting state ready."
kubectl get tasks,taskruns -n starfleet
kubectl get tasks,taskruns -n default
echo "[lab] Running the right Task with tkn is the task."
