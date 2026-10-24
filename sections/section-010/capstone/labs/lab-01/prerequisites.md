# Prerequisites

Before starting this capstone you should be able to:

- Read the `Succeeded` condition, `status.steps` and `status.results` of a `TaskRun`.
- Find the pod of a `TaskRun` and read the log of one step container.
- Explain which folders the steps of a `Task` share, and in which order they run.

## What the environment gives you

The capstone environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Tekton Pipelines v1.17.1** and the `tkn` command-line tool, version **0.46.2**.
- The namespace `starfleet` with the failed TaskRun `inspect-run`, and the Task `inspect` somewhere in the cluster.

## Working rules

- Everything is graded on the **final cluster state**. Leave the Task, the ServiceAccount and the TaskRun in place.
- Each fix shows the next fault. Expect to create the TaskRun more than once.
