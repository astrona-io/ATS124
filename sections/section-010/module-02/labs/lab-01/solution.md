# Solution: Repair A Two-Task Pipeline

Work the task yourself first. Running `astrona submit -c sections/section-010/module-02/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the PipelineRun `roster-run` uses the Pipeline `roster` with the crew `bridge scout probe`, ran both pipeline tasks and succeeded; its result `report` is `roster has 3 names, first: bridge`; and a new run with two names and its own `volumeClaimTemplate` reports `roster has 2 names, first: alpha`.

## Step 1: Read the Succeeded condition

Start with the PipelineRun itself:

```sh
kubectl get pipelinerun roster-run -n starfleet
kubectl get pipelinerun roster-run -n starfleet -o jsonpath='{.status.conditions[0].reason}{"\n"}{.status.conditions[0].message}{"\n"}'
```

The `SUCCEEDED` column shows `False`. The message says that the Task `read-rosters` could not be found. List the TaskRuns of the run and compare the Task names:

```sh
kubectl get taskruns -n starfleet -l tekton.dev/pipelineRun=roster-run
kubectl get tasks -n starfleet
kubectl get pipeline roster -n starfleet -o jsonpath='{range .spec.tasks[*]}{.name}{" -> "}{.taskRef.name}{"\n"}{end}'
```

There is no TaskRun, because the controller could not resolve the Pipeline's Tasks before it started any. The Pipeline refers to `read-rosters`, and the Task is called `read-roster`.

## Step 2: Fix the Pipeline

A Pipeline can be edited. Save this as `pipeline-roster.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: roster
  namespace: starfleet
spec:
  params:
    - name: crew
      type: string
  workspaces:
    - name: shared
  tasks:
    - name: write
      taskRef:
        name: write-roster
      params:
        - name: crew
          value: $(params.crew)
      workspaces:
        - name: shared
          workspace: shared
    - name: read
      taskRef:
        name: read-roster
      params:
        - name: count
          value: $(tasks.write.results.count)
      workspaces:
        - name: shared
          workspace: shared
  results:
    - name: report
      type: string
      value: $(tasks.read.results.report)
```

Apply it:

```sh
kubectl apply -f pipeline-roster.yaml
```

## Step 3: Create the PipelineRun again

A started PipelineRun cannot be edited; the old one also kept a copy of the broken Pipeline in `status.pipelineSpec`. Delete it. Then save this as `pipelinerun-roster-run.yaml`. It also fixes the second fault: the Pipeline declares a workspace `shared`, and the old run did not bind it.

```sh
kubectl delete pipelinerun roster-run -n starfleet
```

```yaml
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: roster-run
  namespace: starfleet
spec:
  pipelineRef:
    name: roster
  params:
    - name: crew
      value: "bridge scout probe"
  workspaces:
    - name: shared
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 16Mi
```

Apply it:

```sh
kubectl apply -f pipelinerun-roster-run.yaml
```

Then check the result:

```sh
kubectl wait --for=condition=Succeeded pipelinerun/roster-run -n starfleet --timeout=240s
kubectl get pipelinerun roster-run -n starfleet -o jsonpath='{.status.results[?(@.name=="report")].value}{"\n"}'
```

It prints `roster has 3 names, first: bridge`. If the run fails again, read the condition message again: the second fault shows only after the first is fixed, because each check happens at a different time.

## Step 4: Submit

```sh
astrona submit -c sections/section-010/module-02/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Rename the Task `read-roster` to `read-rosters` | The Pipeline would work, but the grader requires the Task `read-roster` to stay as it is |
| Embed the steps with `pipelineSpec` | The Pipeline `roster` stays broken; the grader requires `pipelineRef` |
| Bind the workspace to an `emptyDir` | The run starts, but `read` runs in another pod and finds no roster, so it fails |
| Type `3` in the Pipeline instead of the result reference | The run works for three names, but the grader's run with two names reports the wrong count |
| Edit `roster-run` with `kubectl edit` | The webhook rejects changes to the `spec` of a started run |

## Common mistakes

- Looking for pods before the controller created any TaskRun. A resolution failure leaves no TaskRun.
- Fixing the Pipeline and expecting the old run to start again. A run never runs twice.
- Forgetting that every pipeline task is a separate pod, so `/workspace` is not shared.

## Practice on your own

- Add a third pipeline task `archive` with `runAfter: [read]` that prints the roster, and run the Pipeline again.
- Read `status.childReferences` and the labels of the TaskRuns of your successful run.
- Delete the PipelineRun and check that its PersistentVolumeClaim is deleted too.
