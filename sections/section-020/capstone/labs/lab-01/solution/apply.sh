#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the capstone stays broken for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARD="https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.73.0"

# 1. Bring the webhook and the controller back.
kubectl -n tekton-pipelines scale deployment tekton-pipelines-webhook --replicas=1
kubectl -n tekton-pipelines scale deployment tekton-pipelines-controller --replicas=1
kubectl -n tekton-pipelines rollout status deployment/tekton-pipelines-webhook --timeout=300s
kubectl -n tekton-pipelines rollout status deployment/tekton-pipelines-controller --timeout=300s

# 2. Switch the Dashboard to read-only: remove the full release, then apply
#    the read-only one (kubectl apply alone would keep the edit bindings).
kubectl delete -f "$DASHBOARD/release-full.yaml" --ignore-not-found --wait=true
kubectl apply -f "$DASHBOARD/release.yaml"
kubectl -n tekton-pipelines rollout status deployment/tekton-dashboard --timeout=300s

# 3. The smoke test. The webhook may need a few seconds after its rollout.
for attempt in $(seq 1 30); do
  kubectl apply -f "$SCRIPT_DIR/task-smoke.yaml" && break
  echo "[test] Task apply failed (attempt $attempt), retrying..."
  sleep 5
done
kubectl -n starfleet delete taskrun smoke-run --ignore-not-found --wait=true
kubectl apply -f "$SCRIPT_DIR/taskrun-smoke-run.yaml"
kubectl -n starfleet wait --for=condition=Succeeded taskrun/smoke-run --timeout=300s
