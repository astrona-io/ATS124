#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this, so the lab stays broken for the learner.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

reason() {
  kubectl -n starfleet get taskrun "$1" -o jsonpath='{.status.conditions[0].reason}'
}

# 1. Record the reason of every failed run.
kubectl -n starfleet create configmap triage \
  --from-literal=r-missing-task="$(reason r-missing-task)" \
  --from-literal=r-missing-param="$(reason r-missing-param)" \
  --from-literal=r-step-fail="$(reason r-step-fail)" \
  --from-literal=r-timeout="$(reason r-timeout)"

# 2. Create the run that works.
kubectl apply -f "$SCRIPT_DIR/taskrun-r-fixed.yaml"
kubectl -n starfleet wait --for=condition=Succeeded taskrun/r-fixed --timeout=300s
