#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the lab stays broken for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Fix the Pipeline: refer to the Task read-roster.
kubectl apply -f "$SCRIPT_DIR/pipeline-roster.yaml"

# 2. A started PipelineRun cannot be changed: delete it and create it again
#    with the workspace bound.
kubectl -n starfleet delete pipelinerun roster-run --ignore-not-found --wait=true
kubectl apply -f "$SCRIPT_DIR/pipelinerun-roster-run.yaml"
kubectl -n starfleet wait --for=condition=Succeeded pipelinerun/roster-run --timeout=300s
