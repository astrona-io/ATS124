---
estimated_duration: 30m
---

# Repair A Multi-Step Task

- **ID:** CAPSTONE
- **Slug:** ats-124-capstone-010
- **Author:** Paris Nakita Kejser
- **Type:** Astrona graded capstone

Graded capstone for section 010, in the namespaces `starfleet` and `default`. Read `question.md` for the task; `solution.md` is the walkthrough.

> **Not yet run.** This capstone was written from the Tekton v1.17.1
> documentation and has not passed `astrona test` yet.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-124-capstone-010
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-124-capstone-010`), not
the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition, bootstrap and grading |
| `question.md` | The task |
| `solution.md` | Step-by-step walkthrough |
| `prerequisites.md` | Assumed knowledge and what the environment provides |
| `bootstrap/` | tkn CLI and Tekton Pipelines, then the broken starting state |
| `manifests/` | The namespace `starfleet`, the Task `inspect` (in `default`, steps swapped) and the TaskRun `inspect-run` |
| `solution/` | Reference solution used by `astrona test`, with the fixed Task, the ServiceAccount and the TaskRun |
| `testing/` | Waits for the Tekton Deployments |
| `validation/` | Grading scripts, one per check |
