# Inspect And Clean Up TaskRuns

Starting a Task is the easy part. The real work begins when someone asks why a run failed yesterday, what value a run returned, or why the namespace holds three hundred old TaskRuns and their pods. `tkn` has a command for each of those questions. This part lists, describes and reads TaskRuns, and then deletes the ones you no longer need.

## List and describe TaskRuns

First start one more run of the Task `hello`, this time with the value `nobody` for `crew`, a name prefix, and without `--showlog`, so that the list has a run whose result looks wrong:

<!-- astrona:playground:renew -->

```sh
tkn task start hello -n starfleet -p crew=nobody --prefix-name nobody
```

This run succeeds anyway, because the script only prints. That is a useful reminder that a `TaskRun` checks exit codes, not meaning. Now list all TaskRuns in the namespace:

```sh
tkn taskrun list -n starfleet
```

The table has one line per `TaskRun`, newest first, with its name, when it started, how long it took and its status, such as `Succeeded` or the reason of a failure. Add the Task name to list only its runs (`tkn taskrun list hello -n starfleet`), or `--label` to filter by a label such as `tekton.dev/task=hello`. The short name `tr` works too: `tkn tr list`.

`tkn taskrun describe` shows everything about one run. With `--last` it picks the newest `TaskRun`, so you do not need to copy its name:

```sh
tkn taskrun describe --last -n starfleet
```

The output starts with the name, the namespace, the Task it ran, the ServiceAccount and the timeout. Then come the status with its reason, the parameters it got, the results it reported, and a table of steps with the status of each one. For a failed run, the status message and the step table point at the step that failed. The results section shows `greeting` with the value the step wrote, so you rarely need a `jsonpath` expression for a result.

## Read the logs

`tkn taskrun logs` reads the logs of every step container of a `TaskRun`, in the order of the steps, and puts the step name in front of each line:

```sh
tkn taskrun logs --last -n starfleet
```

You see the step name `greet` in brackets and the text `Hello, nobody!`. The flags change what you see: `-f` follows a run that is still going, `-s greet` shows only that step, `-a` adds the init containers that Tekton injects, such as `prepare` and `place-scripts`, and `-t` adds timestamps. `tkn` reads the same pod logs that `kubectl logs <pod> -c step-greet` reads; once the pod is deleted, the logs are gone too.

## Clean up

Every `TaskRun` keeps its pod, and both stay until someone deletes them. A namespace that runs Tasks all day fills up fast. Deleting a `TaskRun` also deletes its pod, because the pod is owned by the `TaskRun`. Delete the run for `nobody` by name. Copy its name, which starts with `nobody-`, from `tkn taskrun list`, and use it in place of `<NAME>`:

```sh
tkn taskrun delete <NAME> -n starfleet
```

`tkn` asks for a confirmation; answer `y`. Add `-f` to skip the question. Instead of names, you can also delete by rule:

| Command | What it deletes |
| --- | --- |
| `tkn taskrun delete NAME...` | The named TaskRuns |
| `tkn taskrun delete --task hello` | All TaskRuns of the Task `hello` (the Task stays) |
| `tkn taskrun delete --task hello --keep 2` | All TaskRuns of `hello` except the 2 newest |
| `tkn taskrun delete --all` | All TaskRuns in the namespace |

Keep the newest runs of `hello` and delete the rest:

```sh
tkn taskrun delete --task hello --keep 2 -n starfleet -f
```

Then check the result with `tkn taskrun list -n starfleet`: only the two newest runs of `hello` are left. By default `tkn taskrun delete` skips TaskRuns that are still running, so a cleanup does not kill work in progress. In real clusters a tool such as the Tekton Pruner does this cleanup on a schedule.

You can now list TaskRuns, describe one with `--last`, read its results and its logs, and delete runs by name, by Task or by count. Together with `tkn task start` and kubeconfig contexts, that covers the daily work with `tkn`: start the right Task in the right namespace, see what it did, and keep the namespace tidy.

## Common pitfalls

> [!WARNING]
> - **Using `--all` when you meant `--task`.** `--all` deletes every TaskRun in the namespace, from every Task.
> - **Reading only the status column.** `Succeeded` means every step exited with 0, not that the result is right. Read the results with `tkn taskrun describe`.
> - **Expecting logs after a cleanup.** Deleting a TaskRun deletes its pod, and the logs with it.
> - **Forgetting `-f` in a script.** Without it, `tkn taskrun delete` waits for a confirmation.

## Your mission: Run A Parameterised Task With tkn

You can now start a Task with `tkn` in the right namespace, read its results and logs, and clean up runs you do not want. The graded lab gives you the Task `hello` in two namespaces and asks you to run the right one with the right parameter, and to leave no stray runs behind.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-124-playground-030-01
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-030/module-01/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/module-01/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-124-lab-030-01
astrona start ats-124-playground-030-01
```
