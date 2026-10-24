#!/usr/bin/env bash
# PASS when the Tekton Dashboard v0.73.0 runs in tekton-pipelines in
# read-only mode and sees Tekton Pipelines v1.17.1. Rejects the read/write
# release (isReadOnly false, or its edit ClusterRoleBindings).
set -uo pipefail

available="$(kubectl -n tekton-pipelines get deployment tekton-dashboard -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' 2>/dev/null)"
if [ "$available" != "True" ]; then
  echo "FAIL: the Deployment tekton-dashboard in tekton-pipelines is not Available."
  exit 1
fi

properties=""
for _ in $(seq 1 10); do
  properties="$(kubectl get --raw /api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/v1/properties 2>/dev/null)"
  [ -n "$properties" ] && break
  sleep 3
done
if [ -z "$properties" ]; then
  echo "FAIL: the Dashboard did not answer /v1/properties through its Service tekton-dashboard."
  exit 1
fi
compact="$(printf '%s' "$properties" | tr -d ' \n')"
case "$compact" in
  *'"dashboardVersion":"v0.73.0"'*) ;;
  *) echo "FAIL: the Dashboard is not v0.73.0: $properties"; exit 1 ;;
esac
case "$compact" in
  *'"isReadOnly":true'*) ;;
  *) echo "FAIL: the Dashboard is not read-only (isReadOnly is not true). Install release.yaml, not release-full.yaml."; exit 1 ;;
esac
case "$compact" in
  *'"pipelinesVersion":"v1.17.1"'*) ;;
  *) echo "FAIL: the Dashboard does not see Tekton Pipelines v1.17.1: $properties"; exit 1 ;;
esac

for binding in tekton-dashboard-backend-edit tekton-dashboard-pipelines-edit; do
  if kubectl get clusterrolebinding "$binding" >/dev/null 2>&1; then
    echo "FAIL: the ClusterRoleBinding $binding of the read/write Dashboard exists."
    exit 1
  fi
done

echo "PASS: the Tekton Dashboard v0.73.0 runs read-only and sees Tekton Pipelines v1.17.1."
exit 0
