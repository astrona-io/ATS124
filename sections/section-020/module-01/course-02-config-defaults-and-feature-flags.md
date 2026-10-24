# Configure Defaults And Feature Flags

A TaskRun that hangs runs for a whole hour before Tekton stops it, unless someone changed the default. A TaskRun that names no ServiceAccount runs as the ServiceAccount `default`, unless someone changed that too. Those defaults live in one ConfigMap, and a second ConfigMap switches whole features on and off. This part shows where the defaults come from, how to change them, and when a change takes effect.

## Where a TaskRun gets its defaults

Start with a TaskRun that sets neither a timeout nor a ServiceAccount. It uses `generateName`, so the API server adds a random suffix and you can create it as often as you like.

<!-- astrona:playground:renew -->

Save this as `taskrun-defaults-check.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: defaults-check-
  namespace: starfleet
spec:
  taskSpec:
    steps:
      - name: check
        image: busybox:1.37.0
        script: |
          #!/bin/sh
          echo "Checking the defaults"
```

Create it (`kubectl apply` does not accept `generateName`):

```sh
kubectl create -f taskrun-defaults-check.yaml
```

Then check the result. The command printed the generated name; use it in place of `<NAME>`:

```sh
kubectl get taskrun <NAME> -n starfleet -o jsonpath='{.spec.timeout}{" "}{.spec.serviceAccountName}{"\n"}'
```

It prints `1h0m0s default`. You did not write either value. The tekton-pipelines-webhook wrote them into the `spec` when the API server called it to admit the new TaskRun. The values come from the ConfigMap `config-defaults` in `tekton-pipelines`, or from built-in defaults when the ConfigMap does not set them. Look at it:

```sh
kubectl get configmap config-defaults -n tekton-pipelines -o yaml
```

The ConfigMap holds only one key, `_example`. It is a long comment that lists every setting and its default, but Tekton ignores it. A setting takes effect only as its own key under `data`. These are the settings you meet most often:

| Key | Built-in default | What it sets |
| --- | --- | --- |
| `default-timeout-minutes` | `60` | `spec.timeout` of TaskRuns and PipelineRuns that set none |
| `default-service-account` | `default` | `spec.serviceAccountName` of runs that set none |
| `default-managed-by-label-value` | `tekton-pipelines` | The `app.kubernetes.io/managed-by` label on TaskRun pods |
| `default-pod-template` | none | A pod template merged into every run, for example a node selector |
| `default-resolver-type` | none | The resolver used when a `taskRef` names no resolver and no Task name |

## Change a default

Set the default timeout to 20 minutes. A `kubectl patch` with `--type merge` adds or changes one key and leaves the others alone:

```sh
kubectl patch configmap config-defaults -n tekton-pipelines --type merge -p '{"data":{"default-timeout-minutes":"20"}}'
```

The webhook and the controller watch this ConfigMap, so you do not restart anything. A second Tekton webhook configuration, `config.webhook.pipeline.tekton.dev`, also checks the ConfigMap when you change it, so a value that is not a number is refused. Now create a second TaskRun from the same file:

```sh
kubectl create -f taskrun-defaults-check.yaml
```

Read its `spec.timeout` with the same command as before and the new name. It shows `20m0s`. Read the first TaskRun again: it still shows `1h0m0s`. The webhook writes the defaults into a TaskRun once, when the TaskRun is created, so a change to `config-defaults` only affects TaskRuns created after it.

The default ServiceAccount works the same way, with one extra trap. If `default-service-account` names a ServiceAccount that does not exist in the namespace of a run, every TaskRun that sets no ServiceAccount fails: the controller cannot create a pod for a ServiceAccount that is not there. The name is only a default for every namespace; it does not create anything. When you change it, make sure the ServiceAccount exists in every namespace that runs TaskRuns, or give each TaskRun its own `serviceAccountName`.

## Feature flags

The ConfigMap `feature-flags` in `tekton-pipelines` switches features on and off for the whole installation. Unlike `config-defaults`, it ships with real keys under `data`. Read it:

```sh
kubectl get configmap feature-flags -n tekton-pipelines -o yaml
```

The keys you should know at the start are these:

| Key | Value in v1.17.1 | What it does |
| --- | --- | --- |
| `enable-api-fields` | `beta` | Which API fields are allowed: `stable`, `beta` or `alpha` |
| `enable-step-actions` | `true` | Allows steps to use a `StepAction` with `ref` |
| `results-from` | `termination-message` | Where the controller reads results from; `sidecar-logs` allows larger results |
| `set-security-context` | `true` | Gives the containers Tekton injects (init containers, sidecars) a restricted security context. It does not change your steps |
| `coschedule` | `workspaces` | How the pods of one PipelineRun are placed on nodes when they share a volume |
| `keep-pod-on-cancel` | `false` | Whether the pod of a cancelled TaskRun is kept for debugging |

Change a flag with `kubectl patch`, the same way as a default, and only when a Task or a page asks for it. An `alpha` value for `enable-api-fields`, for example, allows fields that may change in the next release.

You now know where every TaskRun gets its timeout and ServiceAccount, how to change them in `config-defaults`, and that a change only affects TaskRuns created afterwards. You also know where the feature switches live. The open question is how to see all of this without `kubectl`: the Tekton Dashboard.

## Common pitfalls

> [!WARNING]
> - **Editing the `_example` block.** Tekton ignores it. Add the setting as its own key under `data`.
> - **Expecting old TaskRuns to change.** The webhook writes defaults into the `spec` once, at creation. Create a new TaskRun to see a new default.
> - **Setting a default ServiceAccount that does not exist.** Every TaskRun without its own `serviceAccountName` then fails before its pod is created. Create the ServiceAccount, or set the default back.
> - **Reading `default-timeout-minutes` as a maximum.** It is only the value for runs that set no `timeout`. A TaskRun can still ask for more.
