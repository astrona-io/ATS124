#!/usr/bin/env bash
# Creates the starting state for ats-124-lab-010-03.
#
# 1. Applies the Tasks echo-name, fail-fast and sleeper.
# 2. Applies four TaskRuns that fail for four different reasons.
# 3. Waits until all four have ended, so the learner starts from the failures.
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
  # wait_for_taskrun_end NAME: waits until Succeeded is True or False.
  local status=""
  for _ in $(seq 1 60); do
    status="$(kubectl -n starfleet get taskrun "$1" \
      -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}' 2>/dev/null || true)"
    if [ "$status" = "True" ] || [ "$status" = "False" ]; then
      echo "[lab] TaskRun $1 ended with Succeeded=$status."
      return 0
    fi
    sleep 3
  done
  echo "ERROR: TaskRun $1 did not end in time." >&2
  return 1
}

apply_with_retry "$MANIFESTS/tasks.yaml"
apply_with_retry "$MANIFESTS/taskruns-failed.yaml"
for run in r-missing-task r-missing-param r-step-fail r-timeout; do
  wait_for_taskrun_end "$run"
done

echo "[lab] Starting state ready."
kubectl -n starfleet get tasks,taskruns
echo "[lab] Four TaskRuns failed. Finding out why each one failed is the task."
