#!/usr/bin/env bash
# PASS when the TektonConfig config has profile lite, targetNamespace
# tekton-pipelines, spec.pipeline.default-timeout-minutes 30, and is Ready.
set -uo pipefail

if ! kubectl get tektonconfig config >/dev/null 2>&1; then
  echo "FAIL: the TektonConfig named config does not exist."
  exit 1
fi

profile="$(kubectl get tektonconfig config -o jsonpath='{.spec.profile}')"
if [ "$profile" != "lite" ]; then
  echo "FAIL: profile is '${profile}', expected 'lite'."
  exit 1
fi

target="$(kubectl get tektonconfig config -o jsonpath='{.spec.targetNamespace}')"
if [ "$target" != "tekton-pipelines" ]; then
  echo "FAIL: targetNamespace is '${target}', expected 'tekton-pipelines'."
  exit 1
fi

timeout="$(kubectl get tektonconfig config -o jsonpath='{.spec.pipeline.default-timeout-minutes}')"
if [ "$timeout" != "30" ]; then
  echo "FAIL: spec.pipeline.default-timeout-minutes is '${timeout}', expected 30."
  exit 1
fi

ready=""
for _ in $(seq 1 120); do
  ready="$(kubectl get tektonconfig config -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')"
  [ "$ready" = "True" ] && break
  sleep 5
done
if [ "$ready" != "True" ]; then
  echo "FAIL: the TektonConfig is not Ready (Ready=${ready:-none})."
  exit 1
fi

echo "PASS: the TektonConfig is ready with profile lite and a 30 minute default."
exit 0
