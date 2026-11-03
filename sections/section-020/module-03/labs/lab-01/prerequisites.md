# Prerequisites

Before starting this lab you should be able to:

- Apply a release manifest with `kubectl apply -f`.
- Write a custom resource and read its conditions.
- Explain that the Operator owns the ConfigMaps of the components it installs.

## What the environment gives you

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- The `tkn` command-line tool, version **0.46.2**, on your PATH.
- The namespace `starfleet`. Nothing else: Tekton is not installed.
- Outbound internet access to download the release manifests.

## Working rules

- Everything is graded on the **final cluster state**.
- The installation takes several minutes. The grader waits for it, but give it time before you submit.
