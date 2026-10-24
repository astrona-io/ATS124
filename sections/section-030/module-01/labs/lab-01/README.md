---
estimated_duration: 15m
---

# Run A Parameterised Task With tkn

- **ID:** LAB
- **Slug:** ats-124-lab-030-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona graded lab

Graded lab for the namespaces `starfleet` and `default`. Read `question.md` for the task; `solution.md` is the walkthrough.

Not yet run: this lab was written from the Tekton v1.17.1 documentation and
has not passed `astrona validate` or `astrona test` yet.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-124-lab-030-01
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-124-lab-030-01`), not
the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition, bootstrap and grading |
| `question.md` | The task |
| `solution.md` | Step-by-step walkthrough |
| `prerequisites.md` | Assumed knowledge and what the environment provides |
| `bootstrap/` | tkn CLI and Tekton Pipelines, then the Task `hello` in two namespaces and a stray TaskRun |
| `manifests/` | The namespace `starfleet`, the Task `hello` (starfleet and decoy in default) and the stray TaskRun |
| `solution/` | Reference solution used by `astrona test` (tkn commands) |
| `testing/` | Waits for the Tekton Deployments |
| `validation/` | Grading scripts, one per check |
