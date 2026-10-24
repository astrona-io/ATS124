---
estimated_duration: 25m
---

# Triage And Rerun Work With tkn

- **ID:** CAPSTONE
- **Slug:** ats-124-capstone-030
- **Author:** Paris Nakita Kejser
- **Type:** Astrona graded capstone

Graded capstone for section 030, in the namespace `starfleet`. Read `question.md` for the task; `solution.md` is the walkthrough.

> **Not yet run.** This capstone was written from the Tekton v1.17.1
> documentation and has not passed `astrona test` yet.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-124-capstone-030
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-124-capstone-030`), not
the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition, bootstrap and grading |
| `question.md` | The task |
| `solution.md` | Step-by-step walkthrough |
| `prerequisites.md` | Assumed knowledge and what the environment provides |
| `bootstrap/` | tkn CLI and Tekton Pipelines, then the Task `deploy-check` and four old runs |
| `manifests/` | The namespace `starfleet`, the Task `deploy-check` and the old TaskRuns |
| `solution/` | Reference solution used by `astrona test` (tkn and kubectl commands) |
| `testing/` | Waits for the Tekton Deployments |
| `validation/` | Grading scripts, one per check |
