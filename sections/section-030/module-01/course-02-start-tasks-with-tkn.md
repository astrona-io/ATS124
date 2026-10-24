# Start Tasks With tkn

Running a Task with `kubectl` means writing a `TaskRun` file every time, even when only one value changes. `tkn task start` writes the `TaskRun` for you from the Task name and a few flags, and it can show the logs while the steps run. This part applies a small Task, looks at it with `tkn`, and starts it in different ways.

## A Task to start

The Task `hello` takes one parameter, `crew`, without a default, and reports one result, `greeting`. A parameter is a named input value that a `TaskRun` passes to its Task, and a result is a short output value that a step writes to a file for Tekton to collect.

<!-- astrona:playground:renew -->

Save this as `task-hello.yaml`:

```yaml
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: hello
  namespace: starfleet
spec:
  description: Greets one crew member.
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
        printf 'Hello, %s!' "$(params.crew)" | tee "$(results.greeting.path)"
```

Apply it:

```sh
kubectl apply -f task-hello.yaml
```

Then check the result with `tkn`. The first command lists the Tasks in `starfleet`, and the second shows one Task in detail:

```sh
tkn task list -n starfleet
tkn task describe hello -n starfleet
```

`tkn task describe` shows the name, the namespace and the description, then a table of parameters with their type and default, the results, the steps with their names, and the TaskRuns of this Task. The parameter `crew` has no default, so every run must give it a value.

## Start the Task and follow its logs

`tkn task start` creates a `TaskRun` that refers to the Task. `-p` passes a parameter as `name=value`, and `--showlog` follows the logs of all steps until the run ends:

```sh
tkn task start hello -n starfleet -p crew=bridge --showlog
```

`tkn` first prints the name of the new `TaskRun`, which is the Task name, `-run-` and a random suffix, for example `hello-run-` followed by five characters. Then it streams the log of the step `greet`, with the step name in front of each line, and you see `Hello, bridge!`. `tkn` created the `TaskRun` through the Kubernetes API server, and the Tekton controller ran it as usual. Without `--showlog`, `tkn` prints the name and a hint about how to read the logs, and returns at once.

Leave out `-p` and `tkn` notices that `crew` has no value. In a terminal, it asks you for the value before it creates anything. In a script there is no one to answer, so always pass every parameter without a default. For parameters that do have a default, `--use-param-defaults` takes the defaults without asking.

## Preview, repeat and name runs

Three more flags save time. `--dry-run` builds the `TaskRun` but does not create it, and `--output yaml` prints it:

```sh
tkn task start hello -n starfleet -p crew=scout --dry-run --output yaml
```

The output is a complete `TaskRun` with `generateName: hello-run-`, a `taskRef` to `hello` and the parameter `crew` set to `scout`. You can save it to a file and keep it in Git, or apply it later with `kubectl create -f`. Nothing ran.

`--last` (or `-L`) starts the Task again with the values of its most recent `TaskRun`:

```sh
tkn task start hello -n starfleet --last --showlog
```

The new run greets `bridge` again, without `-p`. `--use-taskrun` does the same with a `TaskRun` you name. And `--prefix-name` replaces the start of the generated name, so `--prefix-name probe-check` gives a `TaskRun` named `probe-check-` plus a suffix, which is easier to find in a long list.

Remember where `tkn` starts the run. With `-n starfleet`, `tkn` looks for the Task in `starfleet` and creates the `TaskRun` there. Without `-n`, it uses the namespace of your kubeconfig context. If a Task with the same name exists in that namespace too, `tkn` starts that one, with no warning.

You can now inspect Tasks with `tkn task list` and `tkn task describe`, and start them with `tkn task start`, its parameters, `--showlog`, `--dry-run`, `--last` and `--prefix-name`. The open question is how to read the runs you started: their status, their results, and their logs after the fact.

## Common pitfalls

> [!WARNING]
> - **Leaving out a parameter without a default in a script.** `tkn` asks for it interactively, which hangs or fails without a terminal. Pass it with `-p`.
> - **Starting the Task in the wrong namespace.** `tkn` uses the context namespace unless you give `-n`. A Task with the same name elsewhere runs instead.
> - **Expecting `--dry-run` to run anything.** It only prints the `TaskRun`.
> - **Passing an array value without commas.** `-p name=a,b,c` gives an array parameter three values; spaces do not separate values.
