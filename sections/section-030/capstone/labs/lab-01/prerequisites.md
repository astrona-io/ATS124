# Prerequisites

Before starting this capstone you should be able to:

- List, describe and read the logs of TaskRuns with `tkn taskrun`.
- Start a Task with several parameters with `tkn task start`.
- Delete chosen TaskRuns with `tkn taskrun delete`.
- Create a ConfigMap with `kubectl create configmap --from-literal`.

## What the environment gives you

The capstone environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` and `tkn` already pointed at it.
- **Tekton Pipelines v1.17.1** and the `tkn` command-line tool, version **0.46.2**.
- The Task `deploy-check` and four old TaskRuns of it in the namespace `starfleet`.

## Working rules

- Everything is graded on the **final cluster state**. Leave the ConfigMap and the TaskRuns in place.
- Use `tkn` to start the new run, so that it gets the name `tkn` gives it.
