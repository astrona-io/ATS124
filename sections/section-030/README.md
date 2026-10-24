# Section 030: Run And Inspect Work With The tkn CLI

With only `kubectl`, starting a Task means writing a TaskRun file, and reading a result means a long `jsonpath` expression. The Tekton command-line tool, `tkn`, turns those jobs into short commands: start a Task with its parameters, follow the logs of every step, describe a run, and delete old runs. Because `tkn` uses your kubeconfig, it also follows the same cluster and namespace rules as `kubectl`, and getting those wrong is the most common way to start a Task in the wrong place.

This section sets up `tkn` and shows how it picks the cluster and namespace. Then you start Tasks with parameters and read their results. Last, you list, describe, read and clean up TaskRuns, which is what you do every day once Tekton runs real work.

**Topic covered:** tkn CLI

## What you will learn

- Installing `tkn` 0.46.2 from its release archive and checking it with `tkn version`.
- How `tkn` chooses the cluster and namespace: kubeconfig contexts, `--context`, `--kubeconfig` and `-n`. `tkn` has no context commands of its own.
- Listing and describing Tasks, and starting them with `tkn task start`, `-p`, `--showlog`, `--use-param-defaults`, `--dry-run` and `--last`.
- Listing and describing TaskRuns, reading results, and reading logs with `tkn taskrun logs` (`--last`, `-f`, `-s`, `-a`).
- Cleaning up with `tkn taskrun delete` (`--task`, `--keep`, `--all`, `-f`).

## The learning path

The section has one module. It has a landing page, three short parts, a graded lab right after the part it tests, and a summary. The module also has its own playground, a cluster where you can explore freely, and the landing page starts it for you.

### 1. Run And Inspect Work With tkn

The module starts at its landing page, which also launches the playground. The playground runs Tekton Pipelines v1.17.1, the read-only Tekton Dashboard v0.73.0, the `tkn` command-line tool and an empty namespace `starfleet`.

1. Set Up tkn And Choose The Cluster And Namespace
2. Start Tasks With tkn
3. Inspect And Clean Up TaskRuns, followed by the lab **Run A Parameterised Task With tkn**
4. Summary

## Section capstone: Triage And Rerun Work With tkn

The capstone is one graded scenario that combines the whole module. The namespace `starfleet` is full of old runs of the Task `deploy-check`, some of them failed. Find out with `tkn` which step failed and which Tekton version runs, record what you found, delete only the failed runs, and start a new run with two parameters. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-030/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-124-capstone-030
```
