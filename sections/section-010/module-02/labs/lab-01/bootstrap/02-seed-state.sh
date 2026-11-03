#!/usr/bin/env bash
# Creates the starting state for ats-124-lab-010-02.
#
# 1. Applies the Tasks write-roster and read-roster.
# 2. Applies the Pipeline roster (it refers to a Task that does not exist).
# 3. Applies the PipelineRun roster-run (it binds no workspace).
# 4. Waits until the PipelineRun has failed, so the learner starts from a failure.
#
# Finding and fixing both faults is the task.
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

wait_for_pipelinerun_end() {
  # wait_for_pipelinerun_end NAME: waits until Succeeded is True or False.
  local status=""
  for _ in $(seq 1 60); do
    status="$(kubectl -n starfleet get pipelinerun "$1" \
      -o jsonpath='{.status.conditions[?(@.type=="Succeeded")].status}' 2>/dev/null || true)"
    if [ "$status" = "True" ] || [ "$status" = "False" ]; then
      echo "[lab] PipelineRun $1 ended with Succeeded=$status."
      return 0
    fi
    sleep 3
  done
  echo "ERROR: PipelineRun $1 did not end in time." >&2
  return 1
}

apply_with_retry "$MANIFESTS/task-write-roster.yaml"
apply_with_retry "$MANIFESTS/task-read-roster.yaml"
apply_with_retry "$MANIFESTS/pipeline-roster.yaml"
apply_with_retry "$MANIFESTS/pipelinerun-roster-run.yaml"
wait_for_pipelinerun_end roster-run

echo "[lab] Starting state ready."
kubectl -n starfleet get tasks,pipelines,pipelineruns
echo "[lab] The PipelineRun roster-run failed. Finding out why and fixing it is the task."
