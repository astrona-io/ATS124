#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the lab stays unsolved for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Set the two defaults. A patch keeps every other key.
kubectl -n tekton-pipelines patch configmap config-defaults --patch-file "$SCRIPT_DIR/defaults-patch.yaml"

# 2. Give the webhook a moment to see the new ConfigMap, then create the run.
sleep 10
kubectl apply -f "$SCRIPT_DIR/taskrun-after.yaml"
kubectl -n starfleet wait --for=condition=Succeeded taskrun/after --timeout=300s
