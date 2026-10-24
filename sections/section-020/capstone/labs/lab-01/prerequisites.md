# Prerequisites

Before starting this capstone you should be able to:

- Name the Deployments of Tekton Pipelines and say what each one does.
- Read why the API server refuses an object, and what an admission webhook is.
- Install the Tekton Dashboard and tell the read-only release from the read/write release.

## What the environment gives you

The capstone environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Tekton Pipelines v1.17.1** and the **Tekton Dashboard v0.73.0** in `tekton-pipelines`, in the state the task describes.
- The `tkn` command-line tool, version **0.46.2**, on your PATH.
- An empty namespace `starfleet`.

## Working rules

- Everything is graded on the **final cluster state**. Leave the Deployments, the Dashboard, the Task and the TaskRun in place.
- Repair the installation; do not reinstall Tekton Pipelines.
- The grader creates a TaskRun of its own, so new runs must start and succeed.
