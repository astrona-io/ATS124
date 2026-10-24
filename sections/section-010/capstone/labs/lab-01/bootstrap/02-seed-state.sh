#!/usr/bin/env bash
# Creates the starting state for ats-124-capstone-010.
#
# 1. Applies the Task inspect to the namespace default (not starfleet), with
#    the steps summarize and scan in the wrong order.
# 2. Applies the TaskRun inspect-run in starfleet. It asks for the
#    ServiceAccount inspector, which does not exist.
# 3. Waits until the TaskRun has failed.
#
# Finding and fixing the three faults is the task.
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

if kubectl -n starfleet get serviceaccount inspector >/dev/null 2>&1; then
  echo "[lab] ERROR: the ServiceAccount inspector already exists; the starting state is wrong." >&2
  exit 1
fi

apply_with_retry "$MANIFESTS/task-inspect-default.yaml"
apply_with_retry "$MANIFESTS/taskrun-inspect-run.yaml"
wait_for_taskrun_end starfleet inspect-run

echo "[lab] Starting state ready."
kubectl -n starfleet get taskruns
echo "[lab] The TaskRun inspect-run failed. Finding and fixing every fault is the task."
