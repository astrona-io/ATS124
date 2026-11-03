# Prerequisites

Before starting this lab you should be able to:

- Start a Pipeline with `tkn pipeline start`, with `-p` and `--prefix-name`.
- Read runs with `tkn pipelinerun list` and `describe`.
- Cancel a run and delete runs with `--pipeline` and `--keep`.

## What the environment gives you

The lab environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Tekton Pipelines v1.17.1** in the namespaces `tekton-pipelines` and `tekton-pipelines-resolvers`.
- The `tkn` command-line tool, version **0.46.2**, on your PATH.
- The Pipelines `deliver` and `wait-forever`, the running PipelineRun `stuck`, and the succeeded runs `deliver-old-1` to `deliver-old-5` in the namespace `starfleet`.

## Working rules

- Everything is graded on the **final cluster state**.
- Use the namespace `starfleet`.
