# Solution: Triage Four Failed Runs

Work the task yourself first. Running `astrona submit -c sections/section-010/module-03/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the ConfigMap `triage` holds the reason of each of the four failed runs under the name of the run; the four runs are still there and still failed; and the new run `r-fixed` succeeded with the result `hello warp`.

## Step 1: List the reasons

One command shows the state and the reason of every run:

```sh
kubectl get taskruns -n starfleet -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[0].status,REASON:.status.conditions[0].reason
```

All four rows have `STATUS` `False`, and each has a different `REASON`. Read the message of each run too, to understand what the reason means:

```sh
for run in r-missing-task r-missing-param r-step-fail r-timeout; do
  echo "== $run"
  kubectl get taskrun "$run" -n starfleet -o jsonpath='{.status.conditions[0].reason}{"\n"}{.status.conditions[0].message}{"\n"}'
done
```

You should see these four reasons, one per run:

| Run | Reason | Cause |
| --- | --- | --- |
| `r-missing-task` | `TaskRunResolutionFailed` | The `taskRef` names `ghost-task`, which does not exist |
| `r-missing-param` | `TaskRunValidationFailed` | The Task `echo-name` needs the parameter `name` and the run gives none |
| `r-step-fail` | the reason that a failed step writes | The step `boom` exits with code 1 |
| `r-timeout` | `TaskRunTimeout` | The step sleeps for 120 seconds and the timeout is 15 seconds |

## Step 2: Write the ConfigMap

Copy the reasons from the cluster instead of typing them. This reads each reason into the ConfigMap:

```sh
kubectl create configmap triage -n starfleet \
  --from-literal=r-missing-task="$(kubectl get taskrun r-missing-task -n starfleet -o jsonpath='{.status.conditions[0].reason}')" \
  --from-literal=r-missing-param="$(kubectl get taskrun r-missing-param -n starfleet -o jsonpath='{.status.conditions[0].reason}')" \
  --from-literal=r-step-fail="$(kubectl get taskrun r-step-fail -n starfleet -o jsonpath='{.status.conditions[0].reason}')" \
  --from-literal=r-timeout="$(kubectl get taskrun r-timeout -n starfleet -o jsonpath='{.status.conditions[0].reason}')"
```

Check it:

```sh
kubectl get configmap triage -n starfleet -o yaml
```

## Step 3: Create the fixed run

The fault of `r-missing-param` is the missing parameter, so a run that supplies it shows the work can be done. Save this as `taskrun-r-fixed.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: r-fixed
  namespace: starfleet
spec:
  taskRef:
    name: echo-name
  params:
    - name: name
      value: warp
```

Apply it and wait:

```sh
kubectl apply -f taskrun-r-fixed.yaml
kubectl wait --for=condition=Succeeded taskrun/r-fixed -n starfleet --timeout=120s
kubectl get taskrun r-fixed -n starfleet -o jsonpath='{.status.results[?(@.name=="greeting")].value}{"\n"}'
```

The last command prints `hello warp`.

## Step 4: Submit

```sh
astrona submit -c sections/section-010/module-03/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Delete the failed runs and make new ones | The grader needs the four originals and their reasons |
| Type reasons from memory | If one reason differs from what the cluster holds, the check for that key fails |
| Edit `r-missing-param` to add the parameter | The webhook refuses changes to the `spec` of a started run |
| Create `r-fixed` with an embedded `taskSpec` | The grader requires `taskRef` to the Task `echo-name` |

## Common mistakes

- Using the `message` as the value. The grader compares the `reason`, which is a short word, not the sentence.
- Looking for the log of `r-missing-task`. No pod ever existed.
- Leaving out the parameter in `r-fixed`, which fails the same way as `r-missing-param`.

## Practice on your own

- Write a fifth run that fails because a ServiceAccount does not exist, and read its reason and message.
- Read the events of `r-step-fail` with `kubectl describe taskrun r-step-fail -n starfleet`.
- Find the lines for `starfleet/r-timeout` in the controller log.
