# Prerequisites

Before starting this lab you should be able to:

- Explain how `tkn` picks the namespace: the kubeconfig context, or the flag `-n`.
- Start a Task with `tkn task start` and pass a parameter with `-p`.
- List, describe and delete TaskRuns with `tkn taskrun`.

## What the environment gives you

The lab environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` and `tkn` already pointed at it. The current context has no default namespace, so commands without `-n` work in `default`.
- **Tekton Pipelines v1.17.1** and the `tkn` command-line tool, version **0.46.2**.
- A Task named `hello` in `starfleet` and another Task named `hello` in `default`.

## Working rules

- Everything is graded on the **final cluster state**. Leave your TaskRun in `starfleet` in place.
- Start the run with `tkn`, so that it gets the name `tkn` gives it.
