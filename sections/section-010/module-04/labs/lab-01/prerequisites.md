# Prerequisites

Before starting this lab you should be able to:

- Apply a release manifest with `kubectl apply -f`.
- Write a RoleBinding and a ClusterRoleBinding for a ServiceAccount.
- Use `kubectl port-forward` and `curl`.

## What the environment gives you

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Tekton Pipelines v1.17.1** and the `tkn` command-line tool, version **0.46.2**.
- The Pipeline `deliver` in the namespace `starfleet`.
- Outbound internet access to download the Triggers manifests.

## Working rules

- Everything is graded on the **final cluster state**.
- Use the namespace `starfleet`.
