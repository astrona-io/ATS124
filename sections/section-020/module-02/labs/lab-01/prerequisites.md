# Prerequisites

Before starting this lab you should be able to:

- Read the ConfigMap `config-defaults` and explain that it ships with only an `_example` key.
- Use `kubectl patch`, `kubectl get -o jsonpath` and `kubectl apply`.
- Explain that the webhook writes defaults into an object when it is created.

## What the environment gives you

The lab environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Tekton Pipelines v1.17.1** in the namespaces `tekton-pipelines` and `tekton-pipelines-resolvers`.
- The `tkn` command-line tool, version **0.46.2**, on your PATH. You can solve the lab with `kubectl` alone.
- The Task `whoami` and the succeeded TaskRun `before` in the namespace `starfleet`.

## Working rules

- Everything is graded on the **final cluster state**.
- The grader creates its own run of `whoami` after you finish, so the defaults must work for any new run.
