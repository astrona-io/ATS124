# Overview: See How Tekton Runs A Task (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Tekton Pipelines and the `tkn` command-line tool, and gives you an empty namespace for your own Tasks. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Tekton Pipelines v1.17.1**, installed from its release manifest. Tekton Pipelines adds the custom resources `Task`, `TaskRun`, `Pipeline`, `PipelineRun`, `StepAction` and `CustomRun` to Kubernetes. Its Deployments are:

  | Deployment | Namespace | What it does |
  | --- | --- | --- |
  | `tekton-pipelines-controller` | `tekton-pipelines` | Creates one pod for each `TaskRun` and writes its status |
  | `tekton-pipelines-webhook` | `tekton-pipelines` | Sets defaults on and validates Tekton objects when they are created |
  | `tekton-events-controller` | `tekton-pipelines` | Sends CloudEvents about runs, when a sink is configured |
  | `tekton-pipelines-remote-resolvers` | `tekton-pipelines-resolvers` | Fetches Tasks from Git, bundles, Artifact Hub, URLs or other namespaces |

- The Tekton command-line tool `tkn`, version **0.46.2**, on your PATH.
- An empty namespace `starfleet` for your Tasks and TaskRuns.
- The image `busybox:1.37.0`, already loaded on the node, for your steps.

A `Task` is a definition and never runs by itself. A `TaskRun` is one execution of a `Task`; the controller creates one pod for it, with one container per step.

## Helpers

Paste these once in each new terminal. `show_runs` lists the TaskRuns in `starfleet` with their `Succeeded` condition. `show_pod` prints the init containers and step containers of the pod of one `TaskRun`. `show_results` prints the results of one `TaskRun`.

```sh
show_runs() {
  kubectl get taskruns -n starfleet
}
show_pod() {
  kubectl get pod "$1-pod" -n starfleet -o jsonpath='{.spec.initContainers[*].name}{"\n"}{.spec.containers[*].name}{"\n"}'
}
show_results() {
  kubectl get taskrun "$1" -n starfleet -o jsonpath='{range .status.results[*]}{.name}{"="}{.value}{"\n"}{end}'
}
```

Use them like this: `show_runs`, `show_pod hello-1`, `show_results hello-2`.

## Practice tasks

- List the Tekton custom resource definitions with `kubectl get crds | grep tekton.dev` and name the API version of each kind with `kubectl api-resources --api-group=tekton.dev`.
- Write a `Task` with three steps that use three different images you know, run it, and compare the order of `.spec.containers` in its pod with the order of the steps.
- Add `onError: continue` to a step that runs `exit 3`, run the `Task`, and read `status.steps` of the `TaskRun`. Which steps ran after the failing one, and what is the final `Succeeded` condition?
- Write a step that runs `ls -la /tekton /tekton/results /workspace` and read its log. Name each folder and what writes into it.
- Run a `TaskRun` with an embedded `taskSpec` instead of `taskRef`, and compare `status.taskSpec` of both kinds of `TaskRun`.
- Scale `tekton-pipelines-controller` to zero with `kubectl -n tekton-pipelines scale deployment tekton-pipelines-controller --replicas=0`, create a `TaskRun`, and look at its status. Scale it back to `1` and watch the run start.
