# Solution: Triage And Rerun Work With tkn

Work the task yourself first. Running `astrona submit -c sections/section-030/capstone/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the ConfigMap `triage` records `failed-step` = `validate` and `pipelines-version` = `v1.17.1`; only the failed runs were deleted; and a new `deploy-check-run-...` ran with `crew` = `shuttle` and `deck` = `3` and reports `Hello, shuttle on deck 3!`.

## Step 1: Find the failed runs

List the runs of the Task:

```sh
tkn taskrun list deploy-check -n starfleet
```

Four runs are listed. Two show the status `Succeeded`. The other two, `deploy-check-run-g5h6i` and `deploy-check-run-j7k8l`, show a failed status.

## Step 2: Find the step that failed

Describe one of the failed runs:

```sh
tkn taskrun describe deploy-check-run-g5h6i -n starfleet
```

The parameters show `crew` = `probe` and `deck` = `9`. In the steps table, the step `validate` failed and the step `announce` did not run. Read the log of that step:

```sh
tkn taskrun logs deploy-check-run-g5h6i -n starfleet -s validate
```

It prints `Deck 9 does not exist`. The other failed run, for `shuttle` on deck `12`, fails in the same step for the same reason. The step name is `validate`.

## Step 3: Find the Tekton version

```sh
tkn version
```

The Pipeline version line shows `v1.17.1`.

## Step 4: Record the triage

```sh
kubectl create configmap triage -n starfleet --from-literal=failed-step=validate --from-literal=pipelines-version=v1.17.1
```

Then check the result:

```sh
kubectl get configmap triage -n starfleet -o yaml
```

## Step 5: Delete only the failed runs

Name both failed runs; `-f` skips the confirmation:

```sh
tkn taskrun delete deploy-check-run-g5h6i deploy-check-run-j7k8l -n starfleet -f
```

`tkn taskrun delete --task deploy-check` would delete the runs that succeeded too, and `--keep 2` keeps the newest two, which are not necessarily the ones that succeeded. Naming the runs is the precise way here.

## Step 6: Start the new run

Pass both parameters and follow the log:

```sh
tkn task start deploy-check -n starfleet -p crew=shuttle -p deck=3 --showlog
```

The log shows `Deck 3 exists` from the step `validate`, then `Hello, shuttle on deck 3!` from the step `announce`. Then check the result:

```sh
tkn taskrun describe --last -n starfleet
```

The status is `Succeeded`, and the results show `greeting` = `Hello, shuttle on deck 3!`.

## Step 7: Submit

```sh
astrona submit -c sections/section-030/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `tkn taskrun delete --all -n starfleet -f` | The two runs that succeeded are deleted too. The grader requires them |
| `tkn taskrun delete --task deploy-check --keep 2` | It keeps the two newest runs by creation time, which are not necessarily the two that succeeded |
| Writing `failed-step: announce` | `announce` never ran; the step table shows `validate` as the failed step |
| Starting the run with `-p deck=03` | The script only accepts `1` to `5` exactly, so the run fails |

## Common mistakes

- Reading the version from `tkn version` before the cluster answers. Make sure the Pipeline line is there.
- Typing `1.17.1` without the `v`. Record the value exactly as `tkn` prints it.
- Forgetting `-n starfleet`. The namespace `default` has no `deploy-check`.

## Practice on your own

- Start `deploy-check` with only `-p crew=probe` and `--use-param-defaults`, and check which deck it used.
- Rerun one of the successful old runs with `tkn task start deploy-check --use-taskrun deploy-check-run-a1b2c -n starfleet`.
