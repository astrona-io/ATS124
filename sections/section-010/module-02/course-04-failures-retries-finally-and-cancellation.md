# Failures, Retries, finally And Cancellation

Sooner or later a Task of a Pipeline fails, and the Pipeline must decide what happens to the others. Should the dependent Tasks run, should the failed Task try again, and must a cleanup Task still run? This part runs a Pipeline whose first Task always fails, adds a retry and a `finally` Task, and then ends runs with a timeout and with a cancellation.

## A Pipeline with a failing Task

Two small Tasks are enough. `fail-always` prints a line and exits with code 1. `say` prints the message it receives.

<!-- astrona:playground:renew -->

Save this as `tasks-failure-demo.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: fail-always
  namespace: starfleet
spec:
  steps:
    - name: fail
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        echo "This step always fails"
        exit 1
---
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: say
  namespace: starfleet
spec:
  params:
    - name: message
      type: string
  steps:
    - name: say
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        echo "$(params.message)"
```

Apply it:

```sh
kubectl apply -f tasks-failure-demo.yaml
```

The Pipeline has three pipeline tasks. `flaky` fails and may retry once. `after` runs only after `flaky`. `cleanup` is listed under `finally`, which means it runs after all other tasks have ended, whether they succeeded or not. It can read the overall outcome from `$(tasks.status)`.

Save this as `pipeline-with-finally.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: with-finally
  namespace: starfleet
spec:
  tasks:
    - name: flaky
      retries: 1
      taskRef:
        name: fail-always
    - name: after
      runAfter:
        - flaky
      taskRef:
        name: say
      params:
        - name: message
          value: "This should not run"
  finally:
    - name: cleanup
      taskRef:
        name: say
      params:
        - name: message
          value: "Pipeline status: $(tasks.status)"
```

Apply it:

```sh
kubectl apply -f pipeline-with-finally.yaml
```

Then run it. Save this as `pipelinerun-with-finally-1.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: with-finally-1
  namespace: starfleet
spec:
  pipelineRef:
    name: with-finally
```

Apply it:

```sh
kubectl apply -f pipelinerun-with-finally-1.yaml
```

## Read what happened

Wait until the run has failed, then read its reason and its children:

```sh
kubectl wait --for=condition=Succeeded=False pipelinerun/with-finally-1 -n starfleet --timeout=180s
kubectl get pipelinerun with-finally-1 -n starfleet -o jsonpath='{.status.conditions[0].reason}{"\n"}'
kubectl get pipelinerun with-finally-1 -n starfleet -o jsonpath='{range .status.childReferences[*]}{.pipelineTaskName}{"\n"}{end}'
```

The reason is `Failed`. Only two TaskRuns exist, `flaky` and `cleanup`. The pipeline task `after` has no TaskRun, because its parent failed. The controller records it as skipped:

```sh
kubectl get pipelinerun with-finally-1 -n starfleet -o jsonpath='{range .status.skippedTasks[*]}{.name}{"\n"}{end}'
```

It prints `after`. The `finally` Task did run, and its log shows the aggregate status that the Pipeline passed in:

```sh
kubectl logs with-finally-1-cleanup-pod -n starfleet -c step-say
```

The line says `Pipeline status: Failed`. Last, the retry. Tekton does not create a second TaskRun for a retry. It runs the same TaskRun again and stores the earlier attempt in `status.retriesStatus`:

```sh
kubectl get taskrun with-finally-1-flaky -n starfleet -o jsonpath='{range .status.retriesStatus[*]}{.conditions[0].reason}{"\n"}{end}'
```

The list has one entry, `StepFailed`, for the first attempt. The current status of the TaskRun is the second attempt, which failed in the same way.

## End a PipelineRun by time or by hand

A `PipelineRun` has the same two ways to end as a TaskRun, with its own field names. `spec.timeouts` takes up to three durations: `pipeline` for the whole run, `tasks` for the tasks without `finally`, and `finally` for the `finally` tasks. `spec.status` set to `Cancelled` stops the run. In both cases the controller cancels the TaskRuns that are still running.

Save this as `pipelinerun-slow-timeout.yaml`. It embeds a small Pipeline with `pipelineSpec`, so no extra object is needed:

```yaml
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: slow-timeout
  namespace: starfleet
spec:
  timeouts:
    pipeline: 30s
  pipelineSpec:
    tasks:
      - name: wait
        taskSpec:
          steps:
            - name: sleep
              image: busybox:1.37.0
              script: |
                #!/bin/sh
                sleep 120
```

Apply it:

```sh
kubectl apply -f pipelinerun-slow-timeout.yaml
kubectl wait --for=condition=Succeeded=False pipelinerun/slow-timeout -n starfleet --timeout=120s
kubectl get pipelinerun slow-timeout -n starfleet -o jsonpath='{.status.conditions[0].reason}{"\n"}'
```

The reason is `PipelineRunTimeout`. To cancel by hand, start a run without a timeout. Save this as `pipelinerun-slow-cancel.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: slow-cancel
  namespace: starfleet
spec:
  pipelineSpec:
    tasks:
      - name: wait
        taskSpec:
          steps:
            - name: sleep
              image: busybox:1.37.0
              script: |
                #!/bin/sh
                sleep 120
```

Apply it, then patch `spec.status` while it runs:

```sh
kubectl apply -f pipelinerun-slow-cancel.yaml
kubectl patch pipelinerun slow-cancel -n starfleet --type=merge -p '{"spec":{"status":"Cancelled"}}'
kubectl wait --for=condition=Succeeded=False pipelinerun/slow-cancel -n starfleet --timeout=60s
kubectl get pipelinerun slow-cancel -n starfleet -o jsonpath='{.status.conditions[0].reason}{"\n"}'
```

The reason is `Cancelled`. The value `CancelledRunFinally` also stops the running tasks but still runs the `finally` tasks.

You can now tell what a failure does to the rest of a Pipeline: dependent tasks are skipped, `retries` repeats the TaskRun, `finally` always runs, and a timeout or a cancel ends the run. With that, you can read any failed `PipelineRun` from its status.

## Common pitfalls

> [!WARNING]
> - **Expecting a retry to create a new TaskRun.** The same TaskRun runs again; earlier attempts are in `status.retriesStatus`.
> - **Putting cleanup in the normal task list.** If an earlier task fails, the cleanup task is skipped. Use `finally`.
> - **Using `Succeeded` as the only check.** A `PipelineRun` with skipped tasks can end as `Failed` or `Completed`; read the reason and `skippedTasks`.
> - **Cancelling with `kubectl delete`.** Deleting removes the run and its TaskRuns. Patch `spec.status` instead.
