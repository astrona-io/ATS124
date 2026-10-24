# Solution: Run A Parameterised Task With tkn

Work the task yourself first. Running `astrona submit -c sections/section-030/module-01/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks two things: a TaskRun `hello-run-...` in `starfleet` ran `hello` with `crew` = `bridge` and reports `Hello, bridge!`; and `default` holds no TaskRun while both Tasks `hello` still exist.

## Step 1: Find both Tasks

List the Tasks in both namespaces:

```sh
tkn task list -n starfleet
tkn task list -n default
```

Both list a Task named `hello`. Your current kubeconfig context has no default namespace, so a `tkn` command without `-n` would use `default` and the old copy. Describe the right one:

```sh
tkn task describe hello -n starfleet
```

It has one parameter, `crew`, of type string and without a default, one result, `greeting`, and one step, `greet`.

## Step 2: Start the Task in starfleet

Pass the namespace and the parameter, and follow the log:

```sh
tkn task start hello -n starfleet -p crew=bridge --showlog
```

`tkn` prints the name of the new TaskRun, which starts with `hello-run-`, then streams the log of the step `greet`: `Hello, bridge!`. If you see `Wrong namespace, bridge.`, you started the copy in `default`; that run must be deleted in Step 4.

## Step 3: Read the result

Describe the newest TaskRun in `starfleet`:

```sh
tkn taskrun describe --last -n starfleet
```

The status is `Succeeded`, the parameter `crew` is `bridge`, and the results section shows `greeting` with the value `Hello, bridge!`.

## Step 4: Clean up default

List the runs in `default`:

```sh
tkn taskrun list -n default
```

You see the stray run `hello-run-stray`, and any run you started there by mistake. Delete them all without the confirmation question. `--all` deletes TaskRuns only; the Task stays:

```sh
tkn taskrun delete --all -n default -f
```

Then check the result:

```sh
tkn taskrun list -n default
tkn task list -n default
```

The first command finds no TaskRuns, and the second still lists the Task `hello`.

## Step 5: Submit

```sh
astrona submit -c sections/section-030/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| `tkn task start hello -p crew=bridge` without `-n` | The old copy in `default` runs and greets with `Wrong namespace`. The grader finds no good run in `starfleet` and a run in `default` |
| Delete the Task `hello` in `default` | TaskRuns are not owned by their Task, so the stray runs stay. The task forbids deleting a Task, and the grader checks it still exists |
| Write the TaskRun by hand with `kubectl` | It works, but its name does not start with `hello-run-` unless you copy `tkn`'s naming; the task asks for `tkn task start` |
| `tkn taskrun delete --all -n starfleet -f` | Your good run is deleted too |

## Common mistakes

- Forgetting `-f` and wondering why the delete waits. It asks for confirmation.
- Typing `-p crew bridge`. The parameter is one argument, `crew=bridge`.
- Leaving out `-p` and getting an interactive question for `crew`.

## Practice on your own

- Create a kubeconfig context with the default namespace `starfleet` and run the same `tkn` commands with `--context` instead of `-n`.
- Start the Task again with `--last` and compare the parameters of the two runs with `tkn taskrun describe`.
- Print the TaskRun that `tkn` would create with `--dry-run --output yaml`.
