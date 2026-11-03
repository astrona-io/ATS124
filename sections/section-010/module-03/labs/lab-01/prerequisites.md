# Prerequisites

Before starting this lab you should be able to:

- Read the `Succeeded` condition of a `TaskRun`, including its `reason` and `message`.
- Use `kubectl get -o jsonpath` or `-o custom-columns`, `kubectl apply`, `kubectl create configmap` and `kubectl logs`.
- Tell a failure before any pod exists from a failure inside a step.

## What the environment gives you

The lab environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Tekton Pipelines v1.17.1** in the namespaces `tekton-pipelines` and `tekton-pipelines-resolvers`.
- The `tkn` command-line tool, version **0.46.2**, on your PATH. You can solve the lab with `kubectl` alone.
- The Tasks `echo-name`, `fail-fast` and `sleeper`, and four failed TaskRuns in the namespace `starfleet`.

## Working rules

- Everything is graded on the **final cluster state**. Leave the four failed TaskRuns in place; they are the evidence.
- The grader reads the reasons from the cluster. It does not accept a guess.
