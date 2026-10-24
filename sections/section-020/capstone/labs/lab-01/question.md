# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** Installation

## Scenario

Someone "cleaned up" the Tekton installation of the `starfleet` team to save resources. Since then, `kubectl apply` refuses every Tekton object, and the team reports that runs never start. The security team also found that the Tekton Dashboard lets anyone change and delete runs, although the team asked for a read-only Dashboard.

## Your task

1. Find out why the API server refuses Tekton objects, and why runs do not start. Fix both.
2. Make the Tekton Dashboard v0.73.0 read-only, with none of the extra permissions of the read/write release left behind.
3. Prove the installation with this smoke test in `starfleet`: save the Task and the TaskRun below to files and apply them.

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: smoke
  namespace: starfleet
spec:
  params:
    - name: crew
      type: string
  results:
    - name: message
      description: One line that names the crew member
  steps:
    - name: smoke
      image: busybox:1.37.0
      script: |
        #!/bin/sh
        set -eu
        printf 'smoke test passed for %s' "$(params.crew)" | tee "$(results.message.path)"
```

```yaml
apiVersion: tekton.dev/v1
kind: TaskRun
metadata:
  name: smoke-run
  namespace: starfleet
spec:
  taskRef:
    name: smoke
  params:
    - name: crew
      value: probe
```

## Constraints

- Repair the installation in place. Do not delete the namespace `tekton-pipelines` and do not reinstall Tekton Pipelines.
- Do not change the webhook configurations or remove them to get objects accepted.
- Keep the Dashboard in `tekton-pipelines`, installed from the official v0.73.0 release.

## Done when

- `tekton-pipelines-controller`, `tekton-pipelines-webhook`, `tekton-events-controller` and `tekton-pipelines-remote-resolvers` each have a ready replica, and the API server accepts a new Task.
- The Dashboard reports version v0.73.0 in read-only mode, and the ClusterRoleBindings `tekton-dashboard-backend-edit`, `tekton-dashboard-pipelines-edit` and `tekton-dashboard-triggers-edit` do not exist.
- `smoke-run` succeeded with the result `message` = `smoke test passed for probe`, and a new TaskRun of `smoke` starts and succeeds.
