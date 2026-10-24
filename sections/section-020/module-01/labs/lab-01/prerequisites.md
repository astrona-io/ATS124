# Prerequisites

Before starting this lab you should be able to:

- Apply a release manifest with `kubectl apply -f <address>` and wait with `kubectl rollout status`.
- Change a key of a ConfigMap with `kubectl patch` or `kubectl edit`.
- Read `spec.timeout`, `spec.serviceAccountName` and the `Succeeded` condition of a `TaskRun`.

## What the environment gives you

The lab environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Tekton Pipelines v1.17.1** in `tekton-pipelines` and `tekton-pipelines-resolvers`, with changed defaults.
- The `tkn` command-line tool, version **0.46.2**, on your PATH.
- The Task `install-check` in the namespace `starfleet`.

The Tekton Dashboard is not installed.

## Working rules

- Everything is graded on the **final cluster state**. Leave the Dashboard, the ConfigMap and the TaskRun in place.
- Installing the Dashboard needs outbound internet to `infra.tekton.dev` and `ghcr.io`.
- The grader creates a TaskRun of its own to test the defaults.
