#!/usr/bin/env bash
# Creates the starting state for ats-124-lab-020-01.
#
# 1. Changes config-defaults: default-service-account names a ServiceAccount
#    that does not exist (tekton-builder), and default-timeout-minutes is 90.
# 2. Applies the Task install-check in starfleet.
# The Tekton Dashboard is not installed (01-install-tekton.sh leaves it out).
#
# Installing the Dashboard and setting the defaults the team asks for is the task.
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

echo "[lab] Changing config-defaults..."
kubectl patch configmap config-defaults -n tekton-pipelines --type merge \
  -p '{"data":{"default-service-account":"tekton-builder","default-timeout-minutes":"90"}}'

apply_with_retry "$MANIFESTS/task-install-check.yaml"

if kubectl -n tekton-pipelines get deployment tekton-dashboard >/dev/null 2>&1; then
  echo "[lab] ERROR: the Tekton Dashboard is already installed; the starting state is wrong." >&2
  exit 1
fi

echo "[lab] Starting state ready."
kubectl -n tekton-pipelines get deployments
echo "[lab] The installation is not finished. Finishing it is the task."
