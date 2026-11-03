#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the lab stays unsolved for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml
kubectl -n tekton-operator rollout status deployment/tekton-operator --timeout=300s
kubectl -n tekton-operator rollout status deployment/tekton-operator-webhook --timeout=300s

# The webhook of the Operator can refuse the first request while it starts.
for attempt in $(seq 1 30); do
  kubectl apply -f "$SCRIPT_DIR/tektonconfig.yaml" && break
  echo "[test] apply failed (attempt $attempt), retrying in 10s..."
  sleep 10
done

kubectl wait --for=condition=Ready tektonconfig/config --timeout=900s
