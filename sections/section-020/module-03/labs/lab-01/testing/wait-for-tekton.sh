#!/usr/bin/env bash
# Runs after the reference solution is applied.
#
# The Operator reports Ready before the Pipelines webhook always answers, so
# wait until every Tekton Deployment in tekton-pipelines is rolled out.
set -euo pipefail

for deployment in $(kubectl -n tekton-pipelines get deployment -o name); do
  kubectl -n tekton-pipelines rollout status "$deployment" --timeout=300s
done
kubectl get namespace starfleet >/dev/null
echo "[test] Tekton Deployments are ready."
