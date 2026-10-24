# Summary

`tkn` turns the daily work with Tekton into short commands: start a Task, follow its logs, read its results, and clean up old runs. It does that as a client of the Kubernetes API server, so it works wherever your kubeconfig points it.

## What you learned

`tkn` is one binary, installed from a release archive such as `tkn_0.46.2_Linux_x86_64.tar.gz` or `tkn_0.46.2_Darwin_all.tar.gz`, or from a package manager. `tkn version` prints the client version and the versions of the Tekton components it finds in the cluster, read from `pipelines-info` and `dashboard-info`; `--component` prints one of them. The client line appears even when the cluster cannot be reached.

`tkn` has no contexts of its own. It reads the kubeconfig file like `kubectl` and uses the current context, its cluster and its default namespace. The flags `--kubeconfig`, `--context` and `-n` override them on any command. A context with a default namespace, made with `kubectl config set-context`, keeps commands in the right namespace; `kubectl config use-context` switches, and `kubectl config delete-context` removes an old one.

`tkn task list` and `tkn task describe` show Tasks with their parameters, results and steps. `tkn task start` creates a `TaskRun` named after the Task with `-run-` and a suffix: `-p` passes parameters, `--showlog` follows the logs, `--use-param-defaults` takes defaults, `--dry-run --output yaml` prints the `TaskRun` without creating it, `--last` repeats the last values, and `--prefix-name` sets the start of the name. A parameter without a default and without `-p` makes `tkn` ask for it.

`tkn taskrun list` shows runs with their status, `tkn taskrun describe --last` shows the Task, ServiceAccount, parameters, results and steps of the newest run, and `tkn taskrun logs` reads the step logs with `-f`, `-s`, `-a` and `-t`. `tkn taskrun delete` removes runs and their pods by name, with `--task` for one Task, `--keep` to keep the newest, or `--all`; `-f` skips the confirmation. The key facts to remember are these:

- `tkn` works in the current context's namespace unless you pass `-n` or `--context`.
- Pass every parameter without a default with `-p`, especially in scripts.
- `Succeeded` only means the steps exited with 0; read the results.
- Deleting a `TaskRun` deletes its pod and its logs.

<!-- astrona:playground:destroy -->
