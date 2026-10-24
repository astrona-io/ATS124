#!/usr/bin/env bash
# Creates the starting state for ats-124-capstone-020.
#
# 01-install-tekton.sh installed Tekton Pipelines v1.17.1 and the read/write
# Dashboard (release-full.yaml). This script then:
# 1. scales tekton-pipelines-webhook to zero, so the API server refuses every
#    Tekton object,
# 2. scales tekton-pipelines-controller to zero, so no TaskRun starts.
#
# Bringing the installation back and switching the Dashboard to read-only is the task.
set -euo pipefail

echo "[lab] Scaling the Tekton webhook and controller to zero..."
kubectl -n tekton-pipelines scale deployment tekton-pipelines-webhook --replicas=0
kubectl -n tekton-pipelines scale deployment tekton-pipelines-controller --replicas=0
kubectl -n tekton-pipelines wait --for=delete pod -l app.kubernetes.io/name=webhook --timeout=120s || true
kubectl -n tekton-pipelines wait --for=delete pod -l app.kubernetes.io/name=controller --timeout=120s || true

echo "[lab] Starting state ready."
kubectl -n tekton-pipelines get deployments
echo "[lab] The installation is broken. Repairing it is the task."
