#!/usr/bin/env bash
# PASS when config-defaults has default-managed-by-label-value=starfleet-ci,
# a default-pod-template with runAsUser and runAsGroup 1000, and still has the
# _example key.
set -uo pipefail

CM="config-defaults"
NS="tekton-pipelines"

label="$(kubectl -n "$NS" get configmap "$CM" -o jsonpath='{.data.default-managed-by-label-value}' 2>/dev/null)"
if [ "$label" != "starfleet-ci" ]; then
  echo "FAIL: $CM must set default-managed-by-label-value to 'starfleet-ci' (found '${label}')."
  exit 1
fi

template="$(kubectl -n "$NS" get configmap "$CM" -o jsonpath='{.data.default-pod-template}' 2>/dev/null)"
if [ -z "$template" ]; then
  echo "FAIL: $CM has no default-pod-template."
  exit 1
fi
if ! printf '%s\n' "$template" | grep -Eq '^[[:space:]]*runAsUser:[[:space:]]*"?1000"?[[:space:]]*$'; then
  echo "FAIL: default-pod-template must set runAsUser to 1000."
  exit 1
fi
if ! printf '%s\n' "$template" | grep -Eq '^[[:space:]]*runAsGroup:[[:space:]]*"?1000"?[[:space:]]*$'; then
  echo "FAIL: default-pod-template must set runAsGroup to 1000."
  exit 1
fi

example="$(kubectl -n "$NS" get configmap "$CM" -o jsonpath='{.data._example}' 2>/dev/null)"
if [ -z "$example" ]; then
  echo "FAIL: the key _example of $CM was removed. Patch the ConfigMap instead of replacing it."
  exit 1
fi

echo "PASS: $CM sets the managed-by label value and a pod template for user and group 1000."
exit 0
