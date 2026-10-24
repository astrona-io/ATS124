#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the lab stays broken for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Fix the Task: share the file through /workspace instead of /tmp.
kubectl apply -f "$SCRIPT_DIR/task-preflight.yaml"

# 2. A started TaskRun cannot be changed: delete it and create it again with
#    the right parameter name.
kubectl -n starfleet delete taskrun preflight-run --ignore-not-found --wait=true
kubectl apply -f "$SCRIPT_DIR/taskrun-preflight-run.yaml"
kubectl -n starfleet wait --for=condition=Succeeded taskrun/preflight-run --timeout=300s
