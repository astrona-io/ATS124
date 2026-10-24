# Summary

Tekton runs CI/CD work as ordinary Kubernetes pods and describes it with ordinary Kubernetes objects. Once you know how an object becomes a pod, you can read any Tekton failure with the tools you already use for pods.

## What you learned

Tekton is an open-source framework for CI/CD on Kubernetes. It was a founding and graduated project of the Continuous Delivery Foundation and moved to the Cloud Native Computing Foundation in March 2026, where it is an incubating project. Its core, Tekton Pipelines, adds custom resources to the Kubernetes API: `Task` and `TaskRun`, `Pipeline` and `PipelineRun`, `StepAction` and `CustomRun`. A `Task` is a definition that never runs by itself; a `TaskRun` is one execution of it, with its own inputs, pod and status.

The work happens in a few Deployments. tekton-pipelines-webhook checks and defaults every Tekton object when it is created. tekton-pipelines-controller turns each `TaskRun` into a pod and writes its status. The events controller sends CloudEvents, and the remote resolvers in `tekton-pipelines-resolvers` fetch Tasks from Git, bundles, Artifact Hub, URLs or other namespaces. Around Tekton Pipelines sit separate projects: Triggers, the `tkn` command-line tool, the Dashboard, the Catalog, Chains, the Operator, Pipelines-as-Code, Results and the Pruner.

Each `TaskRun` gets one pod named `<taskrun>-pod`, and each step becomes one container named `step-<name>`. The init containers `prepare` and `place-scripts` copy the entrypoint binary and the scripts into shared folders. The entrypoint binary replaces each step's command and starts the step only after the step before it wrote its marker file, so the steps run in order and a failed step stops the rest. Steps share files only through the folders Tekton mounts, such as `/workspace` and `/tekton/results`; `/tmp` belongs to one container.

Parameters bring values in as `$(params.<name>)`, and results bring short values out through `$(results.<name>.path)`, the termination message and `status.results`. The `Succeeded` condition is `Unknown` while a run goes on and `True` or `False` when it ends, and its reason tells you where to look. The key facts to remember are these:

- A `TaskRun` is a pod, and a step is a container.
- A failure before the pod (a missing parameter, a missing `Task`) leaves no pod and no log; read the condition message.
- A failure in a step leaves a pod; read `status.steps` and the step's log.
- A `TaskRun` cannot be edited after it starts; create a new one.

<!-- astrona:playground:destroy -->
