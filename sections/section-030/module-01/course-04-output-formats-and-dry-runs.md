# Output Formats, Dry Runs And Completion

The default output of `tkn` is a table for people. When you write a script, paste a result into a ticket or turn a run into a file, a table is the wrong shape. This part shows how to ask `tkn` for names, YAML or JSON, how to preview a run without creating it, and how to switch on shell completion so that you type less.

## Ask for a different output

Most `tkn` list and describe commands take `-o` (long form `--output`). The values `name`, `yaml` and `json` work for the commands that print Tekton objects. Start a run to have something to look at, then list the runs in each shape.

<!-- astrona:playground:renew -->

```sh
tkn task start hello -n starfleet -p crew=scout --showlog
tkn taskrun list -n starfleet -o name
```

The first command creates a `TaskRun` from the Task `hello` and prints its log. The second prints one name per line, with a resource prefix such as `taskrun.tekton.dev/`. That format suits a shell loop. To drop the header line of the normal table instead, add `--no-headers`:

```sh
tkn taskrun list -n starfleet --no-headers
```

For everything about one run, ask for YAML. It is the full object as the Kubernetes API server stores it, including `status`:

```sh
tkn taskrun describe --last -n starfleet -o yaml
```

Use `-o json` when another program, such as `jq`, reads the output. `tkn` and `kubectl` read the same objects, so a value you find in one is in the other.

## Preview a run with a dry run

`tkn task start` creates a `TaskRun` at once. With `--dry-run`, it prints the `TaskRun` that it would create and sends nothing to the cluster. Combine it with `--output yaml` to get a file:

```sh
tkn task start hello -n starfleet -p crew=shuttle --dry-run --output yaml
```

The printed object uses `generateName` instead of `name`, and lists the parameter `crew` with the value `shuttle`. A file made this way is a good starting point for a `TaskRun` that you want to keep in Git. Create it with `kubectl create -f`, not `kubectl apply -f`, because `generateName` needs `create`.

## Exit codes and scripts

A script needs to know whether a command worked. `tkn` returns exit code `0` when the command worked and a non-zero code when it failed, for example when the Task does not exist. Starting a run with `--showlog` follows the log, but the exit code tells you only whether `tkn` could create and follow the run. To learn whether the run itself succeeded, read its condition:

```sh
kubectl get taskrun -n starfleet -l tekton.dev/task=hello -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.conditions[0].reason}{"\n"}{end}'
```

Each line shows a run name and its reason, such as `Succeeded`. In a pipeline of shell commands, use `tkn ... -o name` to pick the object and `kubectl wait --for=condition=Succeeded` to wait for it.

## Shell completion

`tkn completion` prints a script that teaches your shell to complete commands, flags and even object names. It supports `bash`, `zsh`, `fish` and `powershell`. For the current zsh session:

```sh
source <(tkn completion zsh)
```

After that, `tkn task start he` followed by the Tab key completes the Task name from the cluster. To keep completion in every new session, add the line to your shell start-up file, such as `~/.zshrc`. The bash form needs the `bash-completion` package.

You can now choose the output that fits the job: a table to read, names to loop over, YAML or JSON to store or process, a dry run to preview, and completion to type faster. The open question is how the same commands work for a `Pipeline`, which starts many `TaskRuns` as one unit.

## Common pitfalls

> [!WARNING]
> - **Using `kubectl apply` on a dry-run file.** A file with `generateName` needs `kubectl create`.
> - **Parsing the table output.** Column widths and wording can change. Use `-o name`, `-o json` or `jsonpath`.
> - **Trusting the exit code of `--showlog`.** It reports the command, not the run. Read the `Succeeded` condition.
> - **Forgetting `-n`.** Completion and output both depend on the current namespace.
