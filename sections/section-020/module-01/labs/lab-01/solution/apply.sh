#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the lab starts unfinished for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. The read-only Dashboard.
kubectl apply -f https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.73.0/release.yaml
kubectl -n tekton-pipelines rollout status deployment/tekton-dashboard --timeout=300s

# 2. The defaults the team asks for.
kubectl patch configmap config-defaults -n tekton-pipelines --type merge \
  -p '{"data":{"default-service-account":"default","default-timeout-minutes":"20"}}'
# The webhook reloads the ConfigMap on its own; give it a moment.
sleep 10

# 3. The proof.
kubectl -n starfleet delete taskrun install-check-run --ignore-not-found --wait=true
kubectl apply -f "$SCRIPT_DIR/taskrun-install-check-run.yaml"
kubectl -n starfleet wait --for=condition=Succeeded taskrun/install-check-run --timeout=300s
