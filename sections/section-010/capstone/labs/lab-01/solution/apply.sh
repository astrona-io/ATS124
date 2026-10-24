#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the capstone stays broken for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. The Task in starfleet, with the steps in the order scan, summarize, report.
kubectl apply -f "$SCRIPT_DIR/task-inspect.yaml"
# 2. The ServiceAccount the TaskRun asks for.
kubectl apply -f "$SCRIPT_DIR/serviceaccount-inspector.yaml"
# 3. A started TaskRun cannot change: delete it and create it again.
kubectl -n starfleet delete taskrun inspect-run --ignore-not-found --wait=true
kubectl apply -f "$SCRIPT_DIR/taskrun-inspect-run.yaml"
kubectl -n starfleet wait --for=condition=Succeeded taskrun/inspect-run --timeout=300s
