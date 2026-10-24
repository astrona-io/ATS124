# Install Tekton Pipelines From The Release Manifest

There are several ways to install Tekton: the Tekton Operator, packages from cloud and platform vendors, and the release manifest. The release manifest is the base of all of them, and it is the way the Tekton documentation starts. If you can install from it and check the result, you can read any Tekton installation. This part installs Tekton Pipelines v1.17.1 on your empty playground, walks through what it created, and proves it with a TaskRun.

## Check the cluster first

Tekton Pipelines v1.17.1 needs Kubernetes 1.28 or later, and the Tekton Dashboard v0.73.0, which you install later, needs 1.34.0 or later. You also need the right to create cluster-wide objects such as CRDs and ClusterRoles, which the `kind` user has. Check the server version:

<!-- astrona:playground:renew -->

```sh
kubectl version
```

The `Server Version` line names the Kubernetes version of your `kind` node. It must be 1.34 or later for everything in this module.

## Apply the release manifest

Every Tekton Pipelines release publishes one YAML file that holds the whole installation. You apply it by its address, with the version in the path:

```sh
kubectl apply -f https://infra.tekton.dev/tekton-releases/pipeline/previous/v1.17.1/release.yaml
```

`kubectl` prints one line per object it creates: namespaces, ClusterRoles and bindings, CRDs, ConfigMaps, Deployments, Services and webhook configurations. The address `.../pipeline/latest/release.yaml` also exists, but it always points at the newest release, so the result changes over time. Pin the version, as above.

The objects exist now, but the pods still have to start. Wait for each Deployment:

```sh
kubectl -n tekton-pipelines rollout status deployment/tekton-pipelines-controller
kubectl -n tekton-pipelines rollout status deployment/tekton-pipelines-webhook
kubectl -n tekton-pipelines rollout status deployment/tekton-events-controller
kubectl -n tekton-pipelines-resolvers rollout status deployment/tekton-pipelines-remote-resolvers
```

Each command ends with a line saying that the Deployment was successfully rolled out. The images come from `ghcr.io` and are pinned by digest in the manifest, so the first start depends on your network.

## What the release created

The release created two namespaces. `tekton-pipelines` holds the core components, and `tekton-pipelines-resolvers` holds the remote resolvers, which fetch Tasks from Git, OCI bundles, Artifact Hub, HTTP addresses or other namespaces. The namespace `tekton-pipelines` carries the label `pod-security.kubernetes.io/enforce: restricted`, so only pods that meet the restricted Pod Security Standard can run there. Do not run your TaskRuns in it; use your own namespaces, such as `starfleet`.

| Object | Where | What it is for |
| --- | --- | --- |
| Deployment `tekton-pipelines-controller` | `tekton-pipelines` | Creates the pods of TaskRuns and the TaskRuns of PipelineRuns, and writes their status |
| Deployment `tekton-pipelines-webhook` | `tekton-pipelines` | Sets defaults on and validates Tekton objects when they are created or changed |
| Deployment `tekton-events-controller` | `tekton-pipelines` | Sends CloudEvents about runs, when a sink is configured |
| Deployment `tekton-pipelines-remote-resolvers` | `tekton-pipelines-resolvers` | Fetches remote Tasks and Pipelines |
| CRDs `tasks`, `taskruns`, `pipelines`, `pipelineruns`, `stepactions`, `customruns` and more | cluster-wide | The Tekton resource kinds |
| `MutatingWebhookConfiguration` and `ValidatingWebhookConfiguration`s | cluster-wide | Tell the API server to call the webhook for Tekton objects |
| ConfigMaps `config-defaults`, `feature-flags`, `pipelines-info` and others | `tekton-pipelines` | Defaults, feature switches, and the installed version |

The webhook configurations explain an error you may meet right after an installation. The API server calls the webhook for every Tekton object. If the webhook pod is not ready yet, the API server cannot reach it and refuses the object with an error that mentions the webhook. Wait a few seconds and apply again. List the webhook configurations to see them:

```sh
kubectl get mutatingwebhookconfigurations,validatingwebhookconfigurations | grep tekton
```

The names end in `pipeline.tekton.dev`: one mutating configuration, which sets defaults, and validating ones, which check objects and the Tekton ConfigMaps.

## Verify the installation

Three quick checks tell you which version runs and whether it works. First, read the version that the release wrote into the ConfigMap `pipelines-info`:

```sh
kubectl get configmap pipelines-info -n tekton-pipelines -o jsonpath='{.data.version}{"\n"}'
```

It prints `v1.17.1`. Second, ask the `tkn` command-line tool, which reads the same ConfigMap through the Kubernetes API:

```sh
tkn version
```

The output names the client version 0.46.2 and the Pipeline version v1.17.1. If `tkn` cannot find a Pipeline version, it cannot read `pipelines-info`, which usually means Tekton is not installed in `tekton-pipelines`.

The third check is the one that counts: run something. Save this as `taskrun-install-check.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: install-check
  namespace: starfleet
spec:
  taskSpec:
    steps:
      - name: check
        image: busybox:1.37.0
        script: |
          #!/bin/sh
          echo "Tekton runs in this cluster"
```

Apply it:

```sh
kubectl apply -f taskrun-install-check.yaml
```

Then check the result:

```sh
kubectl wait --for=condition=Succeeded taskrun/install-check -n starfleet --timeout=180s
tkn taskrun logs install-check -n starfleet
```

The wait ends with a line that the condition was met, and the log shows `Tekton runs in this cluster`. This `TaskRun` embeds its steps with `taskSpec` instead of referring to a `Task`, which is handy for a quick check. The webhook accepted it, the controller created its pod, and the step ran: every part of the installation took part.

You have now installed Tekton Pipelines from its release manifest, you know what it created and why the webhook must be ready before Tekton objects can be applied, and you proved the installation with a TaskRun. The open question is what this installation does by default, for example how long a run may take and which ServiceAccount it uses.

## Common pitfalls

> [!WARNING]
> - **Installing from `latest`.** The `latest` address changes with every release. Pin `previous/v1.17.1` so that the installation matches what you tested.
> - **Applying Tasks right after the install.** If the webhook pod is not ready, the API server refuses Tekton objects with a webhook error. Wait for the rollout, then apply again.
> - **Calling an installation done when the pods run.** Only a TaskRun that succeeds proves that the webhook, the controller and the steps work together.
> - **Running TaskRuns in `tekton-pipelines`.** The namespace enforces the restricted Pod Security Standard, and the Tekton documentation advises against it. Use your own namespaces.
