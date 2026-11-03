# Overview: Operate The Tekton Installation (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Tekton Pipelines and the `tkn` command-line tool, and gives you an empty namespace for your own runs. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Tekton Pipelines v1.17.1**, installed from its release manifest, in the namespaces `tekton-pipelines` and `tekton-pipelines-resolvers`.
- The Tekton command-line tool `tkn`, version **0.46.2**, on your PATH.
- An empty namespace `starfleet` for your Tasks and runs.
- The image `busybox:1.37.0`, already loaded on the node, for your steps.

The ConfigMaps in `tekton-pipelines` are the ones you change in this module. Nothing is changed in advance: `config-defaults` holds only the `_example` key.

## Helpers

Paste these once in each new terminal. `cm` prints the data keys of a Tekton ConfigMap without its long `_example` text. `leases` lists the leader election Leases with their holders. `pods_of` prints the labels and security context of one pod in `starfleet`.

```sh
cm() {
  kubectl get configmap "$1" -n tekton-pipelines -o go-template='{{range $k, $v := .data}}{{if ne $k "_example"}}{{$k}}={{$v}}{{"\n"}}{{end}}{{end}}'
}
leases() {
  kubectl get leases -n tekton-pipelines -o custom-columns=NAME:.metadata.name,HOLDER:.spec.holderIdentity
}
pods_of() {
  kubectl get pod "$1" -n starfleet -o jsonpath='{.metadata.labels}{"\n"}{.spec.securityContext}{"\n"}'
}
```

Use them like this: `cm config-logging`, `leases`, `pods_of as-builder-pod`.

## Practice tasks

- Set `loglevel.webhook` to `debug` in `config-logging`, create a `TaskRun`, and read the webhook log with `kubectl logs -n tekton-pipelines deployment/tekton-pipelines-webhook`. Set it back.
- Scale the controller to three replicas, set `buckets` to `3`, and list the Leases. Which pod holds which Lease?
- Set `default-timeout-minutes` to `1` in `config-defaults`, create a Task that sleeps for two minutes, and compare the timeout in `spec.timeout` of the new run with an older run.
- Add a LimitRange to `starfleet` with a default CPU limit, create a run, and read the `resources` of its containers.
- Create a ResourceQuota of `pods: "1"` and start a Pipeline with two parallel Tasks. What do you see in the `Succeeded` condition of the second TaskRun?
- Put a bad value into `default-pod-template` and read how the webhook refuses it.
