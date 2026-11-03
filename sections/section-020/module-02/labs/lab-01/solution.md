# Solution: Set Defaults For The Installation

Work the task yourself first. Running `astrona submit -c sections/section-020/module-02/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: `config-defaults` holds the managed-by label value and a pod template for user and group `1000`; the run `after` succeeded as user `1000` with the new label on its pod; and a new run created by the grader gets the same result.

## Step 1: Look at the starting point

```sh
kubectl get configmap config-defaults -n tekton-pipelines -o jsonpath='{.data}' | head -c 200; echo
kubectl get taskruns -n starfleet -o custom-columns=NAME:.metadata.name,UID:.status.results[0].value
kubectl get pods -n starfleet -L app.kubernetes.io/managed-by
```

`config-defaults` holds only the key `_example`. The run `before` reports the user id `0`, and its pod carries the label `tekton-pipelines`.

## Step 2: Patch config-defaults

Save this as `defaults-patch.yaml`:

```yaml
data:
  default-managed-by-label-value: "starfleet-ci"
  default-pod-template: |
    securityContext:
      runAsUser: 1000
      runAsGroup: 1000
```

Apply it as a patch, so that the other keys stay:

```sh
kubectl patch configmap config-defaults -n tekton-pipelines --patch-file defaults-patch.yaml
```

The value of `default-pod-template` is YAML text inside the ConfigMap, so the `|` and the indentation matter. The validating webhook refuses a value that is not a valid pod template. Check the result:

```sh
kubectl get configmap config-defaults -n tekton-pipelines -o jsonpath='{.data.default-managed-by-label-value}{"\n"}{.data.default-pod-template}{"\n"}'
```

## Step 3: Create the new run

The webhook applies the new defaults to objects created after it has seen the change, which takes a few seconds. Save this as `taskrun-after.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: after
  namespace: starfleet
spec:
  taskRef:
    name: whoami
```

Apply it and check the result:

```sh
kubectl apply -f taskrun-after.yaml
kubectl wait --for=condition=Succeeded taskrun/after -n starfleet --timeout=120s
kubectl get taskruns -n starfleet -o custom-columns=NAME:.metadata.name,UID:.status.results[0].value
kubectl get pods -n starfleet -L app.kubernetes.io/managed-by
```

The run `after` reports `1000`, and its pod carries `starfleet-ci`. If it still reports `0`, the run was created before the webhook saw the change. A started run cannot be edited, so delete `after` and create it again.

## Step 4: Submit

```sh
astrona submit -c sections/section-020/module-02/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Put `podTemplate` into the `TaskRun` | `after` works, but the grader's own run has no pod template and reports `0` |
| Replace the whole ConfigMap with `kubectl apply` of a new file | The `_example` key disappears, which the grader checks |
| Delete `before` and make it again | The grader needs the old result `0` as proof that the change affects only new runs |
| Edit the Task `whoami` to run as another user | The grader's run is meant to prove the cluster default, not the Task |

## Common mistakes

- Indenting `default-pod-template` wrongly, so that the webhook refuses the patch.
- Creating the run right after the patch and getting the old result.
- Using `kubectl edit` and removing the `_example` key by accident.

## Practice on your own

- Set `default-timeout-minutes` to `5` and read `spec.timeout` of a new run.
- Add a `ResourceQuota` of `pods: "0"` to `starfleet`, start a run, and read its condition.
- Remove your two keys again and check that new runs return to user `0`.
