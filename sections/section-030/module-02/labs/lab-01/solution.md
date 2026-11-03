# Solution: Operate Pipelines With tkn

Work the task yourself first. Running `astrona submit -c sections/section-030/module-02/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: a `ship` run of `deliver` succeeded with the summary `orbit:v1`; `stuck` is cancelled and still exists; and only the `ship` run, `deliver-old-4` and `deliver-old-5` remain as runs of `deliver`.

## Step 1: Look at the starting point

```sh
tkn pipeline describe deliver -n starfleet
tkn pipelinerun list -n starfleet
```

`deliver` has the required parameter `target` and the parameter `tag` with the default `v1`. The list shows `stuck` running and five succeeded old runs.

## Step 2: Deliver once

```sh
tkn pipeline start deliver -n starfleet -p target=orbit --use-param-defaults --prefix-name ship --showlog
```

`-p target=orbit` sets the required parameter, `--use-param-defaults` accepts `v1` for `tag` without asking, and `--prefix-name ship` makes the name start with `ship`. Check the result of the new run:

```sh
tkn pipelinerun describe --last deliver -n starfleet
```

The Results block shows `summary` with the value `orbit:v1`.

## Step 3: Stop the hung run

```sh
tkn pipelinerun cancel stuck -n starfleet
kubectl get pipelinerun stuck -n starfleet -o jsonpath='{.spec.status}{"\n"}'
```

The second command prints `Cancelled`. The record stays, which is what the task asks for.

## Step 4: Keep the newest three runs

```sh
tkn pipelinerun delete --pipeline deliver --keep 3 -n starfleet -f
tkn pipelinerun list deliver -n starfleet
```

The three newest runs of `deliver` are the `ship` run, `deliver-old-5` and `deliver-old-4`, so `deliver-old-1` to `deliver-old-3` are deleted. The run `stuck` belongs to `wait-forever`, so the `--pipeline deliver` filter leaves it alone.

## Step 5: Submit

```sh
astrona submit -c sections/section-030/module-02/labs/lab-01
```
