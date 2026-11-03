# Overview: Follow The Tekton Controllers (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Tekton Pipelines and the `tkn` command-line tool, and gives you an empty namespace for your own runs. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Tekton Pipelines v1.17.1**, installed from its release manifest, with the Deployments `tekton-pipelines-controller`, `tekton-pipelines-webhook` and `tekton-events-controller` in the namespace `tekton-pipelines`.
- The Tekton command-line tool `tkn`, version **0.46.2**, on your PATH.
- An empty namespace `starfleet` for your Tasks, runs and ServiceAccounts.
- The image `busybox:1.37.0`, already loaded on the node, for your steps.

## Helpers

Paste these once in each new terminal. `reasons` lists every TaskRun with its status and reason. `controller_log` filters the controller log for one object. `can_i` asks what a ServiceAccount in `starfleet` may do.

```sh
reasons() {
  kubectl get taskruns -n starfleet -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[0].status,REASON:.status.conditions[0].reason
}
controller_log() {
  kubectl logs -n tekton-pipelines deployment/tekton-pipelines-controller --since=30m | grep "starfleet/$1"
}
can_i() {
  kubectl auth can-i "$1" "$2" -n starfleet --as="system:serviceaccount:starfleet:$3"
}
```

Use them like this: `reasons`, `controller_log t-missing-param`, `can_i list configmaps builder`.

## Practice tasks

- Run `kubectl get mutatingwebhookconfigurations,validatingwebhookconfigurations | grep tekton` and read the `webhooks` of one configuration with `-o yaml`. Which resources does it match, and what is its `failurePolicy`?
- Change `default-service-account` or `default-pod-template` in the ConfigMap `config-defaults`, create a `TaskRun`, and read what the webhook stored with `kubectl get taskrun <name> -o yaml`. Does an older run change?
- Try to apply a ConfigMap `config-defaults` with a bad value for `default-timeout-minutes`, and read the refusal.
- Create a ServiceAccount with a Role that allows `get` on `pods`, run a Task as that account, and use `kubectl auth can-i` to compare it with the `default` account.
- Create a `PipelineRun` of two Tasks with `spec.taskRunTemplate.podTemplate.securityContext.runAsUser` set, and check the `securityContext` of both pods.
- Start the port forward to port `9090` of the controller, read the `tekton` metrics before and after a run, and name which counters changed.
- Scale `tekton-events-controller` to zero, run a Task, and check that the run still succeeds. What does the events controller do for a run?
