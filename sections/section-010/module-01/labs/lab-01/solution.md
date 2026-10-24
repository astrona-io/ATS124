# Solution: Diagnose A Failing TaskRun

Work the task yourself first. Running `astrona submit -c sections/section-010/module-01/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the TaskRun `preflight-run` uses the Task `preflight` with `target` = `bridge`, ran both steps in order and succeeded; its result `summary` is `bridge: 3 checks passed`; and a new run of the Task with four checks reports `probe: 4 checks passed`.

## Step 1: Read the Succeeded condition

Start with the TaskRun itself:

```sh
kubectl get taskrun preflight-run -n starfleet
kubectl get taskrun preflight-run -n starfleet -o jsonpath='{.status.conditions[0].reason}{"\n"}{.status.conditions[0].message}{"\n"}'
```

The `SUCCEEDED` column shows `False`. The reason is `TaskRunValidationFailed`, and the message says that the parameter `target` is missing. Look for a pod:

```sh
kubectl get pods -n starfleet -l tekton.dev/taskRun=preflight-run
```

There is none. The tekton-pipelines-controller compared the TaskRun with the Task before it created a pod. Compare the parameter names:

```sh
kubectl get task preflight -n starfleet -o jsonpath='{.spec.params[*].name}{"\n"}'
kubectl get taskrun preflight-run -n starfleet -o jsonpath='{.spec.params[*].name}{"\n"}'
```

The Task declares `target` and `checks`; the TaskRun passes `targets`. `target` has no default, so the run cannot start.

## Step 2: Create the TaskRun again with the right parameter

A TaskRun cannot be edited after it started; the webhook rejects changes to its `spec`. Delete it and create it again under the same name:

```sh
kubectl delete taskrun preflight-run -n starfleet
```

Save this as `taskrun-preflight-run.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: preflight-run
  namespace: starfleet
spec:
  taskRef:
    name: preflight
  params:
    - name: target
      value: bridge
```

Apply it:

```sh
kubectl apply -f taskrun-preflight-run.yaml
```

Then check the result after a few seconds:

```sh
kubectl get taskrun preflight-run -n starfleet -o jsonpath='{.status.conditions[0].reason}{"\n"}{range .status.steps[*]}{.name}{" exit "}{.terminated.exitCode}{"\n"}{end}'
```

The run fails again, this time with the reason `StepFailed`. `status.steps` shows `collect` with exit code `0` and `verify` with a non-zero exit code. This time there is a pod, so read the log of the failed step:

```sh
kubectl logs preflight-run-pod -n starfleet -c step-verify
```

`grep` reports that `/tmp/checks.txt` does not exist.

## Step 3: Share the file through /workspace

`collect` wrote `/tmp/checks.txt` in its own container. `verify` runs in a different container with its own `/tmp`, so the file is not there. Tekton mounts the `emptyDir` folder `/workspace` into every step container of the pod, so write and read the file there.

Save this as `task-preflight.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: preflight
  namespace: starfleet
spec:
  params:
    - name: target
      type: string
      description: The crew member the checks are for
    - name: checks
      type: string
      description: Space-separated list of systems to check
      default: "engines shields sensors"
  results:
    - name: summary
      description: How many checks passed, and for whom
  steps:
    - name: collect
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        set -eu
        for check in $(params.checks); do
          echo "$check ok" >> /workspace/checks.txt
        done
        echo "Collected the checks for $(params.target)"
    - name: verify
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        set -eu
        passed="$(grep -c ' ok$' /workspace/checks.txt)"
        printf '%s: %s checks passed' "$(params.target)" "$passed" | tee "$(results.summary.path)"
```

Apply it:

```sh
kubectl apply -f task-preflight.yaml
```

## Step 4: Run it once more

The failed TaskRun kept a copy of the old Task in `status.taskSpec`, so it does not pick up the change. Delete it and create it again from the same file:

```sh
kubectl delete taskrun preflight-run -n starfleet
kubectl apply -f taskrun-preflight-run.yaml
kubectl wait --for=condition=Succeeded taskrun/preflight-run -n starfleet --timeout=120s
```

Then check the result:

```sh
kubectl get taskrun preflight-run -n starfleet -o jsonpath='{.status.results[?(@.name=="summary")].value}{"\n"}'
```

It prints `bridge: 3 checks passed`.

## Step 5: Submit

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Edit `preflight-run` with `kubectl edit` | The webhook rejects the change: a started TaskRun cannot change its `spec` |
| Embed the fixed steps in the TaskRun with `taskSpec` | The Task `preflight` stays broken for everyone else; the grader requires `taskRef` |
| Merge `collect` and `verify` into one step | The file is then shared, but the grader requires the two steps |
| Print `3` in `verify` | The result looks right for `bridge`, but the grader's run with four checks reports the wrong count |
| Add a default to `target` | The run starts, but with the default value instead of `bridge` |

## Common mistakes

- Looking for logs of the first failure. The controller failed it before the pod existed.
- Changing the Task and expecting the old TaskRun to rerun. A TaskRun never runs twice.
- Writing the file to `/tekton/results`. That folder is for results only.

## Practice on your own

- Add a third step that runs `cat /workspace/checks.txt`, and check its log.
- Run the Task with `checks` set to one system only and read the result.
- Find the generated `prepare` and `place-scripts` init containers in `preflight-run-pod` and read their state with `kubectl describe pod`.
