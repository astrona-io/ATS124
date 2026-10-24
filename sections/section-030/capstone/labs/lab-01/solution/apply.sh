#!/usr/bin/env bash
# Reference solution, applied only by `astrona test` (the `testing:` block).
# `astrona run` never runs this.
# Taken from solution.md - if one changes, change the other.
set -euo pipefail

BIN_DIR="/usr/local/bin"
[ -w "$BIN_DIR" ] || BIN_DIR="$HOME/.local/bin"
export PATH="$BIN_DIR:$PATH"

# 1. Record the triage: the failed step and the Tekton Pipelines version.
# The learner reads the Pipeline version line of `tkn version`; tkn reads it
# from the ConfigMap pipelines-info, so the reference reads the same value.
tkn version
version="$(kubectl -n tekton-pipelines get configmap pipelines-info -o jsonpath='{.data.version}')"
kubectl -n starfleet create configmap triage \
  --from-literal=failed-step=validate \
  --from-literal=pipelines-version="$version" \
  --dry-run=client -o yaml | kubectl apply -f -

# 2. Delete only the two failed runs.
tkn taskrun delete deploy-check-run-g5h6i deploy-check-run-j7k8l -n starfleet -f

# 3. A new run with two parameters.
tkn task start deploy-check -n starfleet -p crew=shuttle -p deck=3 --showlog
for name in $(kubectl -n starfleet get taskruns -l tekton.dev/task=deploy-check -o jsonpath='{.items[*].metadata.name}'); do
  kubectl -n starfleet wait --for=condition=Succeeded "taskrun/$name" --timeout=180s
done
