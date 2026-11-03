#!/usr/bin/env bash
# PASS when the Deployments tekton-operator and tekton-operator-webhook in the
# namespace tekton-operator are available.
set -uo pipefail

for d in tekton-operator tekton-operator-webhook; do
  if ! kubectl -n tekton-operator get deployment "$d" >/dev/null 2>&1; then
    echo "FAIL: Deployment $d does not exist in tekton-operator."
    exit 1
  fi
  if ! kubectl -n tekton-operator wait --for=condition=Available "deployment/$d" --timeout=120s >/dev/null 2>&1; then
    echo "FAIL: Deployment $d is not available."
    exit 1
  fi
done

echo "PASS: the Tekton Operator is running."
exit 0
