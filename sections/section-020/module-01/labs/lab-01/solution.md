# Solution: Finish A Tekton Installation

Work the task yourself first. Running `astrona submit -c sections/section-020/module-01/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks four things: Tekton Pipelines v1.17.1 still runs; the Dashboard v0.73.0 runs read-only; a new TaskRun without timeout and ServiceAccount gets `20m0s` and `default` and succeeds; and `install-check-run` succeeded with those values.

## Step 1: Look at the installation

Check what runs and which defaults are set:

```sh
kubectl get deployments -n tekton-pipelines
kubectl get configmap config-defaults -n tekton-pipelines -o yaml
```

The first command lists the controller, the webhook and the events controller, but no `tekton-dashboard`. In the ConfigMap, next to the `_example` block, you find two real keys: `default-service-account: tekton-builder` and `default-timeout-minutes: "90"`. Neither matches the team's rules, and the ServiceAccount `tekton-builder` does not exist in `starfleet`:

```sh
kubectl get serviceaccounts -n starfleet
```

Only `default` is listed. With this setting, every TaskRun that names no ServiceAccount would fail before its pod is created.

## Step 2: Install the read-only Dashboard

The rule "nobody may change or delete runs from it" means the read-only release, `release.yaml`. The read/write release, `release-full.yaml`, would give the Dashboard's ServiceAccount the right to change runs in every namespace.

```sh
kubectl apply -f https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.73.0/release.yaml
kubectl -n tekton-pipelines rollout status deployment/tekton-dashboard
```

Check its mode through the Kubernetes API server, which can forward a request to the Service:

```sh
kubectl get --raw /api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/v1/properties
```

The JSON shows `"dashboardVersion":"v0.73.0"`, `"pipelinesVersion":"v1.17.1"` and `"isReadOnly":true`. You can also open it with `kubectl -n tekton-pipelines port-forward svc/tekton-dashboard 9097:9097` and `http://localhost:9097`.

## Step 3: Set the defaults

Set both keys in one `kubectl patch`. Setting `default-service-account` to `default` matches the rule; removing the key would have the same effect, because `default` is also the built-in value.

```sh
kubectl patch configmap config-defaults -n tekton-pipelines --type merge -p '{"data":{"default-service-account":"default","default-timeout-minutes":"20"}}'
```

The webhook and the controller pick up the change by themselves within a few seconds.

## Step 4: Prove it with a TaskRun

Create the TaskRun without `timeout` and without `serviceAccountName`, so that both come from the defaults.

Save this as `taskrun-install-check-run.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: install-check-run
  namespace: starfleet
spec:
  taskRef:
    name: install-check
```

Apply it:

```sh
kubectl apply -f taskrun-install-check-run.yaml
```

Then check the result:

```sh
kubectl wait --for=condition=Succeeded taskrun/install-check-run -n starfleet --timeout=180s
kubectl get taskrun install-check-run -n starfleet -o jsonpath='{.spec.timeout}{" "}{.spec.serviceAccountName}{" "}{.status.results[?(@.name=="status")].value}{"\n"}'
```

The second command prints `20m0s default ok`. If you created `install-check-run` before you fixed the defaults, it keeps the old values; delete it and apply the file again.

## Step 5: Submit

```sh
astrona submit -c sections/section-020/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Create a ServiceAccount `tekton-builder` | Runs work again, but they do not run as `default`, which breaks the team's rule. The grader rejects it |
| Install `release-full.yaml` | The Dashboard can change and delete runs; `isReadOnly` is `false` |
| Set `timeout` and `serviceAccountName` in the TaskRun | `install-check-run` looks right, but every other TaskRun still gets the wrong defaults. The grader's own TaskRun shows it |
| Edit the `_example` block | Tekton ignores it, so nothing changes |
| Reinstall Tekton Pipelines to reset `config-defaults` | `kubectl apply` keeps keys the release does not set, and the task forbids a reinstall |

## Common mistakes

- Creating `install-check-run` before the defaults are fixed. Defaults are written into a TaskRun once, at creation.
- Typing `20` without quotes in YAML. ConfigMap values are strings; `kubectl patch` with the JSON above quotes it for you.
- Forgetting that the Dashboard needs outbound internet for its image.

## Practice on your own

- Open the Dashboard and find `install-check-run`, its step and its log.
- Set `default-timeout-minutes` to `1`, run a step that sleeps for 90 seconds, and read the reason of the failed TaskRun. Set it back to `20`.
- Install `release-full.yaml`, list the ClusterRoleBindings with `kubectl get clusterrolebindings -l rbac.dashboard.tekton.dev/subject=tekton-dashboard`, and switch back to read-only cleanly.
