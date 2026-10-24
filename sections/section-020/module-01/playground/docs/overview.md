# Overview: Install Tekton Pipelines And The Dashboard (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the `tkn` command-line tool and an empty namespace, but **without Tekton**: you install Tekton Pipelines and the Tekton Dashboard yourself. There is no task, no `astrona submit` and no pass or fail. Explore, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- The Tekton command-line tool `tkn`, version **0.46.2**, on your PATH.
- An empty namespace `starfleet` for your Tasks and TaskRuns.
- The image `busybox:1.37.0`, already loaded on the node, for your steps.

Tekton is not installed. These are the two manifests you install from; both need outbound internet:

| What | Manifest address |
| --- | --- |
| Tekton Pipelines v1.17.1 | `https://infra.tekton.dev/tekton-releases/pipeline/previous/v1.17.1/release.yaml` |
| Tekton Dashboard v0.73.0, read-only | `https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.73.0/release.yaml` |
| Tekton Dashboard v0.73.0, read/write | `https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.73.0/release-full.yaml` |

## Helpers

Paste these once in each new terminal. `tekton_deployments` lists the Tekton Deployments and their ready replicas. `tekton_defaults` prints the keys set in `config-defaults`. `dashboard_properties` asks the Dashboard for its version and mode through the Kubernetes API server, without a port-forward.

```sh
tekton_deployments() {
  kubectl get deployments -n tekton-pipelines
  kubectl get deployments -n tekton-pipelines-resolvers
}
tekton_defaults() {
  kubectl get configmap config-defaults -n tekton-pipelines -o go-template='{{range $k, $v := .data}}{{$k}}{{"\n"}}{{end}}'
}
dashboard_properties() {
  kubectl get --raw /api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/v1/properties
  echo
}
```

Use them like this: `tekton_deployments`, `tekton_defaults`, `dashboard_properties`.

## Practice tasks

- Install Tekton Pipelines and apply a `Task` at once, before the webhook is ready. Read the error, wait for `kubectl -n tekton-pipelines rollout status deployment/tekton-pipelines-webhook`, and apply again.
- List everything the release created with `kubectl get all -n tekton-pipelines` and `kubectl get crds | grep tekton`. Name the job of each Deployment.
- Set `default-timeout-minutes` to `1`, run a step that runs `sleep 90`, and read the reason of the `Succeeded` condition. Set the value back to `60` afterwards.
- Set `default-service-account` to a name that does not exist, start a TaskRun without `serviceAccountName`, and read its condition message. Then fix it in two different ways.
- Install `release-full.yaml`, compare `dashboard_properties` and the ClusterRoleBindings with the read-only release, then switch back cleanly with `kubectl delete -f` and `kubectl apply -f`.
- Run `tkn version` before and after each install and note which lines appear.
