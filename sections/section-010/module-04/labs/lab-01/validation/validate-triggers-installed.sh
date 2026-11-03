#!/usr/bin/env bash
# PASS when the Triggers controller, webhook and core interceptors Deployments
# are available in tekton-pipelines.
set -uo pipefail

for d in tekton-triggers-controller tekton-triggers-webhook tekton-triggers-core-interceptors; do
  if ! kubectl -n tekton-pipelines get deployment "$d" >/dev/null 2>&1; then
    echo "FAIL: Deployment $d does not exist in tekton-pipelines."
    exit 1
  fi
  if ! kubectl -n tekton-pipelines wait --for=condition=Available "deployment/$d" --timeout=120s >/dev/null 2>&1; then
    echo "FAIL: Deployment $d is not available."
    exit 1
  fi
done

echo "PASS: Tekton Triggers is installed."
exit 0
