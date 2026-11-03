# Prerequisites

Before starting this lab you should be able to:

- Read a `Pipeline` and a `PipelineRun`, including `params`, `workspaces` and `results`.
- Use `kubectl get`, `kubectl apply`, `kubectl delete` and `kubectl logs -c`.
- Explain that every pipeline task runs as its own `TaskRun` with its own pod.

## What the environment gives you

The lab environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Tekton Pipelines v1.17.1** in the namespaces `tekton-pipelines` and `tekton-pipelines-resolvers`.
- The `tkn` command-line tool, version **0.46.2**, on your PATH. You can solve the lab with `kubectl` alone.
- The Tasks `write-roster` and `read-roster`, the Pipeline `roster` and the failed PipelineRun `roster-run` in the namespace `starfleet`.

## Working rules

- Everything is graded on the **final cluster state**. Leave the Tasks, the Pipeline and the PipelineRun in place.
- The grader runs the Pipeline once more with its own values, so it must work for any input.
