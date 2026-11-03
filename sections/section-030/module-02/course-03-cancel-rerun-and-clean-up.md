# Cancel, Rerun And Clean Up

Three things happen to every busy Pipeline: a run hangs and must be stopped, a run must be repeated with the same values, and old runs pile up. This part uses `tkn` for all three. It cancels a run that waits for too long, starts the same Pipeline again from a finished run, and removes old runs by count.

## A run that does not end

Start with a Pipeline that waits. Save this as `pipeline-wait.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: wait
  namespace: starfleet
spec:
  tasks:
    - name: hold
      taskSpec:
        steps:
          - name: sleep
            image: busybox:1.37.0
            script: |
              #!/bin/sh
              echo "waiting"
              sleep 300
```

<!-- astrona:playground:renew -->

Apply it and start a run named `held`:

```sh
kubectl apply -f pipeline-wait.yaml
tkn pipeline start wait -n starfleet --prefix-name held
tkn pipelinerun list wait -n starfleet
```

The status shows `Running`. The run would work for five minutes.

## Cancel a run

`tkn pipelinerun cancel` sets `spec.status` of the run to `Cancelled`, the same change you made with `kubectl patch` for a TaskRun. Take the name from the list:

```sh
tkn pipelinerun cancel $(tkn pipelinerun list wait -n starfleet -o name --limit 1 | sed 's|.*/||') -n starfleet
```

The command inside `$( )` lists the newest run of `wait` by name, and `cut` drops the resource prefix. Check the effect:

```sh
tkn pipelinerun list wait -n starfleet
kubectl get pipelinerun -n starfleet -l tekton.dev/pipeline=wait -o jsonpath='{.items[0].spec.status}{"\n"}'
```

The list shows that the run ended as cancelled, and the second command prints `Cancelled`. The controller stopped the running TaskRun and its pod, and the PipelineRun ended as failed. Its record is still there, which is the reason to cancel instead of deleting.

A TaskRun is cancelled the same way with `tkn taskrun cancel NAME`.

## Run it again

A finished `PipelineRun` never runs again, but you can create a new one with the same values. `--use-pipelinerun` copies the parameters, workspaces and ServiceAccount of an existing run into the new one. First run `deliver` with a value that you want to repeat:

```sh
tkn pipeline start deliver -n starfleet -p target=orbit -p tag=v3 --prefix-name first --showlog
```

Then repeat that run, by its name. The name starts with `first-`; take it from the list:

```sh
tkn pipelinerun list deliver -n starfleet
tkn pipeline start deliver -n starfleet --use-pipelinerun $(tkn pipelinerun list deliver -n starfleet -o name --limit 1 | sed 's|.*/||') --prefix-name second --showlog
```

The second run reports `orbit:v3` as well. You can override one value on top of the copy by adding `-p tag=v4`. Without the flag you would have to type every parameter again. The shortcut `--last` repeats the most recent run of the Pipeline.

```sh
tkn pipeline start deliver -n starfleet --last --showlog
```

## Clean up old runs

Every `PipelineRun` keeps its TaskRuns, pods and, if a `volumeClaimTemplate` made one, a PersistentVolumeClaim, until someone deletes it. Deleting a `PipelineRun` removes all of them, because they are owned by it. The command is `tkn pipelinerun delete`:

| Command | Deletes |
| --- | --- |
| `tkn pipelinerun delete NAME...` | The named runs |
| `tkn pipelinerun delete --pipeline deliver` | All runs of the Pipeline `deliver` |
| `tkn pipelinerun delete --pipeline deliver --keep 3` | All runs of `deliver` except the 3 newest |
| `tkn pipelinerun delete --pipeline deliver --keep-since 60` | All runs of `deliver` except those completed in the last 60 minutes |
| `tkn pipelinerun delete --all` | All runs in the namespace |

Count the runs first, then keep the newest three. The flag `-f` skips the question, which a script needs:

```sh
tkn pipelinerun list deliver -n starfleet --no-headers | wc -l
tkn pipelinerun delete --pipeline deliver --keep 3 -n starfleet -f
tkn pipelinerun list deliver -n starfleet
```

Only the newest three runs of `deliver` are left. By default `tkn` does not delete a run that is still working, so a cleanup does not stop work in progress. For a schedule, a cluster uses a pruner instead of a person with a terminal.

You can now cancel a run, repeat a run, and keep a namespace tidy.

## Common pitfalls

> [!WARNING]
> - **Deleting a hung run to stop it.** Cancel it. The record and the reason stay.
> - **Forgetting `-f` in a script.** The delete command waits for an answer.
> - **Using `--keep` without `--pipeline`.** Name the Pipeline, or the command may not select what you expect.
> - **Expecting `--use-pipelinerun` to reuse the old run.** It creates a new one with copied values.
> - **Cancelling and expecting the status `Succeeded`.** A cancelled run ends as failed, with a reason that says it was cancelled.

## Your mission: Operate Pipelines With tkn

You can now start, read, cancel and clean up Pipeline runs with `tkn`. The graded lab gives you a namespace with a Pipeline, five old runs and one run that hangs, and asks you to deliver once, stop the hung run and keep the namespace tidy.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-124-playground-030-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-030/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-124-lab-030-02
astrona start ats-124-playground-030-02
```
