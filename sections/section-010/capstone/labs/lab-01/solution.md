# Solution: Repair A Multi-Step Task

Work the task yourself first. Running `astrona submit -c sections/section-010/capstone/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the Task `inspect` is in `starfleet` with its steps in the right order; the ServiceAccount `inspector` exists and the pod of `inspect-run` ran as it; and `inspect-run` succeeded with one container per step and the expected result.

## Step 1: Read the first failure

Start with the TaskRun:

```sh
kubectl get taskrun inspect-run -n starfleet -o jsonpath='{.status.conditions[0].reason}{"\n"}{.status.conditions[0].message}{"\n"}'
kubectl get pods -n starfleet -l tekton.dev/taskRun=inspect-run
```

The condition is `False` with the reason `TaskRunResolutionFailed`, and the message says that the Task `inspect` was not found. There is no pod. A `taskRef` without a resolver looks for the Task in the namespace of the TaskRun. Look for the Task in every namespace:

```sh
kubectl get tasks --all-namespaces
```

The Task `inspect` exists only in `default`.

## Step 2: Put the Task in starfleet, with the steps in order

Read the Task before you copy it:

```sh
kubectl get task inspect -n default -o yaml
```

The steps run in the order `summarize`, `scan`, `report`. `summarize` reads `/workspace/scan.txt`, which `scan` writes, so `summarize` would fail on an empty folder. Tekton runs steps exactly in the order of the list. Write the Task to `starfleet` with `scan` first.

Save this as `task-inspect.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: inspect
  namespace: starfleet
spec:
  params:
    - name: target
      type: string
      description: The crew member whose area is inspected
  results:
    - name: report
      description: One line with the number of findings and the status
  steps:
    - name: scan
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        set -eu
        for area in hull deck cargo; do
          echo "$(params.target) $area clear" >> /workspace/scan.txt
        done
        echo "Scanned 3 areas for $(params.target)"
    - name: summarize
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        set -eu
        count="$(grep -c ' clear$' /workspace/scan.txt)"
        echo "$count findings" > /workspace/summary.txt
        cat /workspace/summary.txt
    - name: report
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        set -eu
        printf '%s: %s, status green' "$(params.target)" "$(cat /workspace/summary.txt)" | tee "$(results.report.path)"
```

Apply it:

```sh
kubectl apply -f task-inspect.yaml
```

You may delete the copy in `default` with `kubectl delete task inspect -n default`; the grader does not look at it.

## Step 3: Run it again and read the next failure

The failed TaskRun cannot change. Save its spec to a file, delete it, and create it again. Save this as `taskrun-inspect-run.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: inspect-run
  namespace: starfleet
spec:
  serviceAccountName: inspector
  taskRef:
    name: inspect
  params:
    - name: target
      value: scout
```

Delete the old TaskRun and apply the file:

```sh
kubectl delete taskrun inspect-run -n starfleet
kubectl apply -f taskrun-inspect-run.yaml
```

Then check the result:

```sh
kubectl get taskrun inspect-run -n starfleet -o jsonpath='{.status.conditions[0].status} {.status.conditions[0].reason}{"\n"}{.status.conditions[0].message}{"\n"}'
```

The Task is found now, but the controller cannot create the pod. The message names the ServiceAccount `inspector`, which does not exist in `starfleet`. The pod of a TaskRun runs as the ServiceAccount in `spec.serviceAccountName`, and the controller also reads that ServiceAccount to find credentials, so it must exist before the pod can be created.

## Step 4: Create the ServiceAccount and run once more

Save this as `serviceaccount-inspector.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: inspector
  namespace: starfleet
```

Apply it, then create the TaskRun again:

```sh
kubectl apply -f serviceaccount-inspector.yaml
kubectl delete taskrun inspect-run -n starfleet
kubectl apply -f taskrun-inspect-run.yaml
kubectl wait --for=condition=Succeeded taskrun/inspect-run -n starfleet --timeout=120s
```

## Step 5: Prove the fix

Check the pod, its containers and the result:

```sh
kubectl get pod inspect-run-pod -n starfleet -o jsonpath='{.spec.serviceAccountName}{"\n"}{.spec.containers[*].name}{"\n"}'
kubectl get taskrun inspect-run -n starfleet -o jsonpath='{.status.results[?(@.name=="report")].value}{"\n"}'
```

The first command prints `inspector` and then `step-scan step-summarize step-report`. The second prints `scout: 3 findings, status green`.

## Step 6: Submit

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Remove `serviceAccountName` from the TaskRun | The run uses the ServiceAccount `default` and may succeed, but the grader requires `inspector` |
| Create the TaskRun in `default`, next to the Task | The grader looks for `inspect-run` in `starfleet` |
| Embed the steps with `taskSpec` | The Task stays broken; the grader requires the Task in `starfleet` and a `taskRef` |
| Make `summarize` create the file itself | The step order stays wrong and the result no longer counts what `scan` found |

## Common mistakes

- Trying `kubectl edit taskrun inspect-run`. The webhook rejects every change to the `spec` of a started TaskRun.
- Fixing the order in the copy in `default`. A `taskRef` only looks in the TaskRun's own namespace.
- Looking for logs before a pod exists. The first two failures happen in the controller, before the pod.

## Practice on your own

- Use the cluster resolver to run the Task from `default` without copying it: set `taskRef.resolver: cluster` with the parameters `kind`, `name` and `namespace`.
- Add `onError: continue` to `summarize` in the broken order and read the final reason of the TaskRun.
