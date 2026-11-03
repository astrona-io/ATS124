#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the lab stays unsolved for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
for d in $(kubectl -n tekton-pipelines get deployment -o name | grep triggers); do
  kubectl -n tekton-pipelines rollout status "$d" --timeout=300s
done

kubectl apply -f "$SCRIPT_DIR/trigger-rbac.yaml"
for attempt in $(seq 1 30); do
  kubectl apply -f "$SCRIPT_DIR/triggers.yaml" && break
  echo "[test] apply failed (attempt $attempt), retrying in 10s..."
  sleep 10
done

kubectl -n starfleet rollout status deployment/el-deliver-listener --timeout=300s
kubectl -n starfleet port-forward service/el-deliver-listener 8080 >/dev/null 2>&1 &
PF=$!
sleep 5
curl -fsS -X POST -H 'Content-Type: application/json' -d '{"target":"orbit"}' http://localhost:8080
kill "$PF" 2>/dev/null || true

for _ in $(seq 1 60); do
  RUN="$(kubectl -n starfleet get pipelineruns -o name | grep from-trigger- | head -n 1)"
  [ -n "$RUN" ] && break
  sleep 3
done
kubectl -n starfleet wait --for=condition=Succeeded "$RUN" --timeout=300s
