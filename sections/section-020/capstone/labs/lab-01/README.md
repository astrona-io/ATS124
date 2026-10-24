---
estimated_duration: 30m
---

# Repair A Broken Tekton Installation

- **ID:** CAPSTONE
- **Slug:** ats-124-capstone-020
- **Author:** Paris Nakita Kejser
- **Type:** Astrona graded capstone

Graded capstone for section 020, in the namespaces `tekton-pipelines` and `starfleet`. Read `question.md` for the task; `solution.md` is the walkthrough.

> **Not yet run.** This capstone was written from the Tekton v1.17.1
> documentation and has not passed `astrona test` yet.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-124-capstone-020
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-124-capstone-020`), not
the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition, bootstrap and grading |
| `question.md` | The task |
| `solution.md` | Step-by-step walkthrough |
| `prerequisites.md` | Assumed knowledge and what the environment provides |
| `bootstrap/` | tkn CLI, Tekton Pipelines and the read/write Dashboard, then the webhook and controller scaled to zero |
| `manifests/` | The namespace `starfleet` |
| `solution/` | Reference solution used by `astrona test`, with the Task `smoke` and the TaskRun `smoke-run` from the question |
| `testing/` | Waits for the Tekton Deployments |
| `validation/` | Grading scripts, one per check; `validate-smoke-run.sh` runs its own TaskRun |
