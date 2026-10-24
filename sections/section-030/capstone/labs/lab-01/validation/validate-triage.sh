#!/usr/bin/env bash
# PASS when the ConfigMap triage in starfleet records the failed step
# (validate) and the Tekton Pipelines version (v1.17.1).
set -uo pipefail

if ! kubectl -n starfleet get configmap triage >/dev/null 2>&1; then
  echo "FAIL: the ConfigMap triage does not exist in starfleet."
  exit 1
fi
step="$(kubectl -n starfleet get configmap triage -o go-template='{{index .data "failed-step"}}')"
version="$(kubectl -n starfleet get configmap triage -o go-template='{{index .data "pipelines-version"}}')"
FAILED=0
if [ "$step" != "validate" ]; then
  echo "FAIL: triage failed-step is '${step}'. Name the step that failed in the failed runs."
  FAILED=1
fi
if [ "$version" != "v1.17.1" ]; then
  echo "FAIL: triage pipelines-version is '${version}'. Record the version tkn version reports for Tekton Pipelines."
  FAILED=1
fi
[ "$FAILED" -eq 0 ] || exit 1
echo "PASS: triage records failed-step=validate and pipelines-version=v1.17.1."
exit 0
