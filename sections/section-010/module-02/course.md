# See How A Pipeline Becomes TaskRuns

One Task rarely does the whole job. A release needs a build, a test and a publish, some of them in order and some at the same time. Tekton describes such a group of Tasks as a `Pipeline`. This module runs a Pipeline and shows what Tekton creates for it, so that a failed release is as easy to read as a failed Task.

A `Pipeline` is an ordered graph of Tasks. A `PipelineRun` is one execution of a `Pipeline`. The tekton-pipelines-controller does not run a `PipelineRun` as one pod. It creates one `TaskRun` for each Task of the `Pipeline`, at the moment the Task is allowed to start, and each `TaskRun` gets its own pod.

Keep one sentence in mind: **a `PipelineRun` is a group of `TaskRuns`, and every `TaskRun` is its own pod.** Because each Task runs in its own pod, Tasks do not share files unless you give them a workspace, and values travel between Tasks only as results.

The module has four parts. **Run Your First Pipeline** defines a Pipeline with parallel and ordered Tasks and runs it. **How The Controller Builds A PipelineRun** reads the TaskRuns, owner references, labels and timestamps that the controller creates. **Pass Data Between Tasks** moves values with results and files with a workspace. **Failures, Retries, finally And Cancellation** shows what happens when a Task fails. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Write a `Pipeline` with parallel Tasks and ordered Tasks (`runAfter`), and run it with a `PipelineRun`.
- Find the `TaskRuns` of a `PipelineRun` by label and by `status.childReferences`.
- Explain what the controller creates, in which order, and who owns the objects.
- Pass a result from one Task to another with `$(tasks.<task>.results.<result>)`.
- Share files between Tasks with a workspace backed by a `volumeClaimTemplate`.
- Explain `retries`, `finally`, `timeouts` and `spec.status: Cancelled` of a `PipelineRun`.

## Before you start

You need to know what a `Task` and a `TaskRun` are: a `Task` is a list of steps, and a `TaskRun` is one execution of it with one pod. You should be able to read a `Succeeded` condition and use `kubectl get`, `kubectl apply` and `kubectl logs`.

Your playground is a single-node `kind` cluster with these parts:

| Part of the playground | What it is |
| --- | --- |
| Namespace `tekton-pipelines` | Tekton Pipelines v1.17.1: the controller, the webhook and the events controller |
| Namespace `tekton-pipelines-resolvers` | The remote resolvers |
| Namespace `starfleet` | Empty. Your Tasks, Pipelines and runs go here |
| `tkn` on your PATH | The Tekton command-line tool, version 0.46.2 |

Every command runs against the playground cluster, and `kubectl` already points at it.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
