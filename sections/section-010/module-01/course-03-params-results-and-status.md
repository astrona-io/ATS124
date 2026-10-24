# Parameters, Results And The Status Of A TaskRun

A `Task` that always does the same thing is not very useful. Real Tasks take inputs, such as a Git revision or an image name, and they report small outputs, such as a commit hash or an image digest. When something goes wrong, the `TaskRun` is also where Tekton tells you why. This part adds a parameter and a result to the `hello` Task, and then teaches you to read the status of a `TaskRun` that failed.

## Pass a parameter in

A parameter is a named input value. The `Task` declares it under `spec.params`, and a step uses it as `$(params.<name>)`. Tekton replaces that text with the value before the step starts. A parameter without a `default` must get a value from every `TaskRun`.

The new version of `hello` below declares the parameter `crew` and the result `greeting`. A result is a small named output: the step writes it to the file `$(results.greeting.path)`, which is `/tekton/results/greeting` inside the container.

<!-- astrona:playground:renew -->

Save this as `task-hello-crew.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello
  namespace: starfleet
spec:
  params:
    - name: crew
      type: string
      description: The crew member to greet
  results:
    - name: greeting
      description: The greeting that was printed
  steps:
    - name: greet
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        set -eu
        if [ -z "$(params.crew)" ]; then
          echo "The parameter crew is empty" >&2
          exit 1
        fi
        printf 'Hello, %s!' "$(params.crew)" | tee "$(results.greeting.path)"
```

Apply it:

```sh
kubectl apply -f task-hello-crew.yaml
```

This replaces the two-step `hello` Task with a one-step version. Now run it with a value for `crew`.

Save this as `taskrun-hello-2.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: hello-2
  namespace: starfleet
spec:
  taskRef:
    name: hello
  params:
    - name: crew
      value: scout
```

Apply it:

```sh
kubectl apply -f taskrun-hello-2.yaml
```

Then check the result:

```sh
kubectl wait --for=condition=Succeeded taskrun/hello-2 -n starfleet --timeout=120s
kubectl get taskrun hello-2 -n starfleet -o jsonpath='{.status.results[?(@.name=="greeting")].value}{"\n"}'
```

The second command prints `Hello, scout!`. That value did not come from the log. When the step ended, the entrypoint binary read `/tekton/results/greeting` and put it in the container's termination message, a short text that Kubernetes keeps in the container status. The tekton-pipelines-controller copied it from there to `status.results`. All results of one pod must fit into 4096 bytes together, so results are for short values, not for files.

## Read the Succeeded condition

Every `TaskRun` has one status condition of the type `Succeeded`. Its `status` is `Unknown` while the run goes on, and `True` or `False` when it ends. Its `reason` says why:

| `status` | Common `reason` values | Meaning |
| --- | --- | --- |
| `Unknown` | `Started`, `Pending`, `Running` | The controller picked it up, the pod is waiting, or the steps are running |
| `True` | `Succeeded` | Every step ended with exit code 0 |
| `False` | `StepFailed`, `StepOOM`, `Failed` | A step ended with a non-zero exit code, a step ran out of memory, or the pod failed for another reason |
| `False` | `TaskRunTimeout`, `TaskRunCancelled` | The run took longer than `spec.timeout`, or someone cancelled it |
| `False` | `TaskRunImagePullFailed` | A step image could not be pulled |
| `False` | `TaskRunValidationFailed`, `TaskRunResolutionFailed` | The run was invalid, or its `Task` could not be found, before any pod existed |

The last row matters most when you debug. Some failures happen in the controller before it creates a pod, so there is no pod and no log to read. Other failures happen in a step, so the pod and its logs tell the story. Make one of each, starting with a `TaskRun` that forgets the parameter.

Save this as `taskrun-hello-3.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: hello-3
  namespace: starfleet
spec:
  taskRef:
    name: hello
```

Apply it:

```sh
kubectl apply -f taskrun-hello-3.yaml
```

Then check the result:

```sh
kubectl get taskrun hello-3 -n starfleet -o jsonpath='{.status.conditions[0].status} {.status.conditions[0].reason}{"\n"}{.status.conditions[0].message}{"\n"}'
kubectl get pods -n starfleet -l tekton.dev/taskRun=hello-3
```

The condition is `False`, and the message says that the parameter `crew` is missing. The second command finds no pod. The controller compared the `TaskRun` with the `Task`, found the missing value, and failed the run without creating a pod.

The opposite case is a step that fails. Run `hello` with an empty value, which the script refuses. This time use `kubectl create` with a `generateName`, so the API server picks a new name for you:

Save this as `taskrun-hello-empty.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  generateName: hello-empty-
  namespace: starfleet
spec:
  taskRef:
    name: hello
  params:
    - name: crew
      value: ""
```

Create it (`kubectl apply` does not accept `generateName`):

```sh
kubectl create -f taskrun-hello-empty.yaml
```

Then check the result. The command prints the generated name; use it in place of `<NAME>`:

```sh
kubectl get taskrun <NAME> -n starfleet -o jsonpath='{.status.conditions[0].reason}{"\n"}{range .status.steps[*]}{.name}{" exit "}{.terminated.exitCode}{"\n"}{end}'
kubectl logs <NAME>-pod -n starfleet -c step-greet
```

The reason is `StepFailed`, and `status.steps` shows the step `greet` with exit code `1`. The log of `step-greet` prints `The parameter crew is empty`. Here the pod exists, so the log gives you the cause.

## You cannot edit a TaskRun

After you fix a problem, you might want to edit the failed `TaskRun` and run it again. Tekton does not allow that. The webhook rejects changes to the `spec` of a `TaskRun` that has started, because the `TaskRun` is the record of what ran. To run again, create a new `TaskRun`, or delete the old one and create it again with the same name:

```sh
kubectl delete taskrun hello-3 -n starfleet
```

A new `hello-3` with the parameter set would then create a new pod named `hello-3-pod`. A changed `Task`, on the other hand, affects only TaskRuns created after the change; each `TaskRun` keeps a copy of the `Task` spec it used in `status.taskSpec`.

You can now pass parameters in, read results out, and read the `Succeeded` condition to tell a failure before the pod from a failure in a step. With that, and the pod model of one container per step, you can find the cause of most failed TaskRuns. The open question is how to install and configure Tekton itself, which decides defaults such as the timeout and the ServiceAccount of every run.

## Common pitfalls

> [!WARNING]
> - **Searching for a pod that was never created.** If the reason is about validation or a missing `Task`, the controller failed the run before the pod. Read the condition message instead.
> - **Reading results from the log.** The log and the result are separate. Only what the step wrote to `$(results.<name>.path)` ends up in `status.results`.
> - **Writing a newline into a result by accident.** `echo` adds a newline; `printf` without `\n` does not. The newline becomes part of the value.
> - **Editing a `TaskRun` to retry it.** The `spec` cannot change after it starts. Create a new `TaskRun` or delete and recreate it.
> - **Putting large data into results.** All results of one pod share 4096 bytes. Use `/workspace` or a real volume for files.

## Your mission: Diagnose A Failing TaskRun

You can now read a failed `TaskRun` from its condition, its pod and its step logs, and you know which folders steps share. The graded lab gives you a `TaskRun` that fails twice in a row for two different reasons, and asks you to fix the `Task` and the `TaskRun` until it succeeds with the right result.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-124-playground-010-01
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-010/module-01/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-124-lab-010-01
astrona start ats-124-playground-010-01
```
