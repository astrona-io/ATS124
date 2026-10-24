# Writing style for this repo

All study text here (course pages, lab docs, READMEs, comments in YAML and
scripts) is for people learning a technical subject, often for a
certification exam. Many of them are not native English speakers and have no
university degree.

## Technical documentation in plain English

This is technical documentation. Say exactly what the system does, with the
real technical terms, in clear and simple English. Never hide a concept
behind a metaphor, a made-up name or a vague word: the reader must learn the
words they will meet in the product, the logs and the exam.

Strict guidelines:

1. Use the correct technical term every time (request, response, pod,
   namespace, Service, sidecar proxy, certificate, mTLS, JWT, listener). The
   first time a term appears in a file, define it in one plain sentence that
   says what it is and what it does. Spell out every acronym on first use.
2. No metaphors or analogies in explanations. Not "the communications
   officer", but "the sidecar proxy (Envoy)"; not "a signal", but "a
   request"; not "the planet", but "the namespace".
3. Simple sentences. Target a Flesch-Kincaid Grade Level of 8 or 9 for the
   prose around the terms. Keep sentences direct; split long sentences into
   two. No corporate buzzwords.
4. Use short paragraphs (max 3-4 sentences per paragraph).
5. Use the active voice ("istiod sends the configuration", not "the
   configuration is sent").

## How this applies to course material

- **Know which file you are in.** A module has a short landing page, a few
  deep-dive parts and a summary page. The landing page is a map: goals, what
  to know first, the order of the parts. The real teaching goes in the parts.
  The summary closes the module. A lab
  has a task, a step-by-step solution and a short intro. Keep each file to its
  job. Do not add "Prerequisite: ... Next: ..." navigation lines to pages;
  the landing page and the course outline already give the order.
- **Keep each part short.** One idea per part, about 5 to 8 minutes of
  reading and at most about 8 command blocks, so a learner can finish it with
  the playground in one sitting of about 15 minutes. Split at a natural seam
  where each half ends with something the learner has seen work. Never split
  only to hit a number. When you split, renumber the files, fix every "Part N"
  reference in the module and `astrona.yaml`.
- **Read like a book, not like a web page.** Each part reads as a chapter of
  a technical book. Open with a short paragraph on the problem it solves and
  why it matters. Link each paragraph to the next with a transition sentence.
  Close with a paragraph that sums up what the reader now knows and the
  question still open, before `## Common pitfalls` and the mission. Write
  explanations as prose; keep bullets for real lists (fields, ordered steps,
  options). Use `##` only when the topic changes and `###` only inside a long
  section, never for a single command. Weave hands-on steps into the text:
  one or two sentences on what to run and why, the command, the real output,
  then a sentence or two on what it shows.
- **The module ends with a summary.** The last page of every module is
  `course-0N-summary.md` with the title `# Summary`: a few short prose
  paragraphs on what the reader learned, organised by idea, optionally with
  one short list of key facts. It names no parts, modules, sections or
  chapters, and has no links, lab table, quiz or commands. Its last line is
  `<!-- astrona:playground:destroy -->` on its own line; the platform turns it
  into the step that removes the playground.
- **Every heading gets an intro.** A `##` section that has `###`
  subsections starts with one to three sentences that say what the section
  is about and why it matters, before the first `###`. Never put a `###`
  directly under a `##`.
- **Every module stands on its own.** Never refer to other sections or
  modules: no "see section 040", "as module 3 showed", "you met this in
  section 000", and no links to pages in another module. If the reader needs
  a fact from elsewhere, state the fact directly in one or two sentences.
  This also goes for parts of the same module: never write "Part 2 shows",
  "from Part 1" or "as in Part 3". Say the fact itself ("the commands below
  need the `scout` `DestinationRule` applied"). This includes the summary.
  The landing page does not have a "Where this fits" section.
- **Write words out in full.** Do not use informal short forms in prose:
  write "communications", "configuration", "repository", "administrator",
  "for example" and "that is", never "comms", "config", "repo", "admin",
  "e.g." or "i.e.". Names in code, commands and file paths stay as they are.
- **Exam terms stay.** The product's own names are what the reader must learn
  (for example a resource kind, a field, a command). Use them as they are and
  define each one in plain technical words the first time it appears in a
  file. Spell out acronyms on first use, with a short plain meaning.
- **The space theme is only for examples.** Space appears in two places and
  nowhere else: the names of the example workloads (the Starfleet: `bridge`,
  `scout`, `shuttle`, `probe`, the `starfleet` and `outpost` namespaces) and
  the short scenario that opens a lab task or a practice exercise (for
  example "the `drifter` in `outpost` must keep reaching the probe"). The
  explanation around an example is plain technical text: write "the
  `shuttle` pod sends a request to the `probe` Service", never "the shuttle
  sends a signal to the probe ship". Do not address the reader as an
  astronaut, and do not use space metaphors (communications officer, mission
  control, badge, airlock, guest list, star chart) for Istio or Kubernetes
  concepts. Titles of pages and labs name the technical task ("Require mTLS
  With PeerAuthentication"), not a space story.
- **Show one real example before the rule.** Start with a concrete case the
  reader can run, then give the general rule.
- **Say which part does the work.** Readers often mix up the parts of a system
  that sit close together. Whenever something happens, say which component
  did it.
- **Never change code to fit the style.** Commands, configuration files, field
  names, resource names, log lines and command output stay exactly as they
  are. They were run and checked on a real system. Never make up command
  output. If you shorten it, say that you did.
- **Prose only.** The grade-level and sentence rules apply to explanations.
  They do not apply to code blocks, tables of field names or reference lists
  (those may stay short and dense).
- **Keep the page furniture the same.** Hands-on steps are part of the prose
  (see "Read like a book"), not boxes or headings of their own. A `> [!TIP]` box is
  only for a real tip: advice the reader can reuse beyond this one step (a
  habit, a shortcut, how to spot a problem, an exam habit). Everything else
  is a normal sentence: notes about the current step ("if the log line is
  old, run it again"), background facts, optional extra steps, and plain
  information. Never a command snippet, never two in a row, and most pages
  need zero or one tip. Each part ends with a
  `## Common pitfalls` `> [!WARNING]` block for that part only. Use a Mermaid
  diagram for a flow, an order or a state change, keep it under about 12
  boxes, and follow it with one sentence that says what it shows.
- **Labs come right after the part they practise.** Do not collect all
  graded labs at the end of a module. In `astrona.yaml`, put each lab (its
  `question.md` reading and the `lab` entry) right after the reading part it
  tests. If a part teaches a gradeable skill and no lab covers it, create a
  new lab. That part then ends with a `## Your mission: <lab title>` section:
  one sentence on what the reader can now do, one on what the mission asks,
  then pause the playground (`astrona stop <playground name>`), the
  `astrona run` and `astrona submit` commands, and finally
  `astrona destroy <lab name>` plus `astrona start <playground name>`.
- **Renew the playground before hands-on work.** Every reading part that
  runs commands has `<!-- astrona:playground:renew -->` exactly once, on its
  own line, right before the first hands-on step (the first "Save this as"
  or the first command block), so the playground timer is reset before the
  learner needs the playground. Not on landing pages (they carry
  `<!-- astrona:playground -->`), summary pages (they carry
  `<!-- astrona:playground:destroy -->`) or pages without commands.
- **Mermaid without HTML.** The platform renders Mermaid with HTML labels
  switched off, so `<br/>` and any other HTML tag break the drawing. Rules:
  - One line per box, no `<br/>`, no HTML. Keep the box to the thing's name
    (`"scout-v2"`, `"istiod"`, `"Service: scout"`).
  - Put the logic on the arrows: `E -->|"version: v2"| P2`,
    `I -->|"CDS"| C`, `A -->|"end-user: jason"| B`. Keep edge labels short.
  - Quote every label. Prefer `flowchart TB`; use `LR` only for a short chain.
  - Sequence diagrams: short participant aliases (`participant S as shuttle`)
    and short message text.
  - Anything longer (cluster names, full hostnames) goes in the sentence under
    the diagram.
- **Every course starts with an Introduction.** It lives in `sections/intro/`
  and is the first entry in `astrona.yaml` (`id: module-intro`, title
  "Introduction"). It has exactly these four pages, in this order:
  - `README.md`, `# Introduction`: what the introduction covers and its three
    pages, named in prose (no links), ending with the topic the course starts
    with.
  - `course-01-welcome.md`, `# Welcome To The Course`: who the course is for,
    the exam domain and what the reader can do at the end, the words the
    course uses, the example app, how the course is laid out and how to read
    a page.
  - `course-02-get-your-machine-ready.md`, `# Get Your Machine Ready`: the
    tools to install, the `astrona` commands used every day, and what to do
    when a start goes wrong.
  - `course-03-how-this-course-is-made.md`, `# How This Course Is Made`: how
    content is written and checked, the maintainers, how to report a mistake,
    and the license.
  The Introduction teaches no product content and has no playground, labs or
  summary. Its only links are the repository's contributors page, issues
  page and license.
- **No links to other course files.** A course page (every reading listed in
  `astrona.yaml`, the playground guide `docs/overview.md`, and a lab's
  `question.md` and `solution.md`) never links to or points the reader at
  another page or file of the repository: no links to parts, summaries,
  labs, `question.md`, other modules, sections or the Introduction, and no
  "see `practice.md`" or "open `config.yaml`". The platform shows the pages in
  the order of `astrona.yaml`, so a link only adds a second, often wrong,
  path. Name a thing in plain words when the reader needs it ("the task is on
  the next page"), and state a fact on the page itself instead of sending the
  reader somewhere else. Repository files for authors (the root `README.md`,
  a lab's or playground's `README.md`) may link.
- **No links to outside sources.** Course pages, labs and playground docs do
  not link to or point at outside websites (the one exception is the
  `resources` field of a lab entry in `astrona.yaml`) (official docs, GitHub, blogs,
  RFCs), and they have no "Reference" or "Official docs" lists. Everything the
  reader needs is explained on the page itself. Not affected: addresses the
  reader actually uses in a command or browser (`http://127.0.0.1:9080`,
  `curl https://httpbin.org`), and the Introduction's contributors and
  "report a mistake" links.
- **Configuration goes to a file first.** Whenever the reader should apply
  YAML (course parts, playground docs, labs), use three separate steps:
  1. "Save this as `virtualservice-scout.yaml`:" followed by a plain
     ` ```yaml ` block with only the YAML. No `cat > file <<'EOF'`, no
     `kubectl apply -f - <<EOF`, no shell around it.
  2. "Apply it:" followed by a ` ```sh ` block with only
     `kubectl apply -f virtualservice-scout.yaml`.
  3. "Then check the result:" followed by the check commands, if any.
  The file name says the kind and the object. If a value must come from the
  reader's cluster (an IP address), use a placeholder like `<PARTNER>` in the
  YAML and say how to get the value (`echo $PARTNER`); never put shell
  variables inside YAML. Apply an object the first time its YAML appears; do
  not show it once "to read" and paste it again later. Never tell the reader
  to apply something from the playground's `examples/` folder: they start the
  playground with `astrona run`, so that folder is not on their machine.
- **Helpers have readable names.** Shell helper functions and variables use
  names that say what they do (`check_route`, `count_versions`,
  `$SERVICE_URL`), never single letters.


## About this repo (ATS124 only)

Everything above is general and can be copied to other course repositories. This
section is only true for this one.

### What the student is trying to learn

- **The goal:** master the **Fundamentals, Architecture & tkn CLI** domain of
  the **Tekton** training path (`ATP024`). It is 10% of the path. There is no
  official Tekton certification exam; the path's domains and weights are
  Astrona's own, set in `ATP024/path.yaml` (10/20/25/15/15/15 for ATS124 to
  ATS129).
- **Where Tekton sits:** Tekton is an **incubating project of the Cloud Native
  Computing Foundation (CNCF)**. The CNCF accepted it on 13 March 2026. Before
  that it was a founding and graduated project of the Continuous Delivery
  Foundation (CD Foundation). It is **not** a CNCF graduated project, and it is
  no longer a CD Foundation project. Both foundations belong to the Linux
  Foundation. Say this correctly wherever the course mentions it.
- **What the domain really tests:** running Tekton, not remembering words. The
  student must *do* things (install Tekton Pipelines and the Dashboard, start a
  Task with `tkn`, read a failed TaskRun and its pod, change a default in
  `config-defaults`). Every explanation should lead to a command they can run,
  and every fix should be proved with a TaskRun whose `Succeeded` condition is
  `True` and whose results have the expected values.
- **The three topics:** the execution model and the ecosystem, installing
  Tekton Pipelines and the Dashboard, and the `tkn` command-line tool. The
  README table maps each section to its topic.
- **The sections:**

  | Section | Title | Topic |
  | --- | --- | --- |
  | 010 | Tekton Architecture And The Execution Model | Execution model |
  | 020 | Install Tekton Pipelines And The Dashboard | Installation |
  | 030 | Run And Inspect Work With The tkn CLI | tkn CLI |

- **The versions:** everything is written for **Tekton Pipelines v1.17.1**,
  **Tekton Dashboard v0.73.0** and the **tkn CLI v0.46.2** on a single-node
  `kind` cluster. Pipelines 1.17 needs Kubernetes 1.28 or later; Dashboard
  0.73 needs Kubernetes 1.34.0 or later, so the `kind` node must be at least
  1.34. v1.17 is a monthly release (end of life 31 October 2026); the current
  long-term support (LTS) release is v1.15. Tekton picks four LTS releases a
  year. The ecosystem overview names these versions only for orientation:
  Triggers v0.37.2, Chains v0.29.9, Pipelines-as-Code v0.52.0, Operator
  v0.81.2, Pruner v0.4.4. Do not teach fields, flags or output from other
  versions without saying so.
- **The main sources:** the Tekton documentation, <https://tekton.dev/docs/>,
  and the `docs/` folders of `tektoncd/pipeline` (tag `v1.17.1`),
  `tektoncd/cli` (tag `v0.46.2`) and `tektoncd/dashboard` (tag `v0.73.0`).
  Check every page against them.

### Status: every environment passes `astrona test`

All nine environments (three playgrounds, three labs, three capstones) passed
`astrona test` on 2026-10-25 on a laptop `kind` cluster with Podman. Pages
still describe results in words: add a `text` output block only when it is
pasted exactly from a real run. Run `astrona test` again on every environment
you change.

### Terms, not metaphors

Explanations use Tekton's and Kubernetes' own words. Define each one in plain
technical language on first use in a file, for example:

| Term | First-use definition (example wording) |
| --- | --- |
| Tekton Pipelines | The core Tekton project: custom resources and controllers that run CI/CD work as pods in Kubernetes |
| Continuous integration and delivery (CI/CD) | Building, testing and releasing software automatically on every change |
| Custom resource definition (CRD) | A schema that adds a new resource kind, such as `Task`, to the Kubernetes API |
| `Task` | A reusable list of steps, with parameters and results, stored in one namespace |
| `TaskRun` | One execution of a `Task`; Tekton creates one pod for it |
| Step | One container in the TaskRun's pod; steps run one after the other, in the order of the list |
| `Pipeline` / `PipelineRun` | An ordered graph of Tasks / one execution of it (only named in this course) |
| `StepAction` | A reusable step stored as its own object (`tekton.dev/v1beta1`) and referenced from a step with `ref` |
| `CustomRun` | A run that a controller outside Tekton Pipelines carries out (`tekton.dev/v1beta1`) |
| Parameter (`params`) | A named input value that a TaskRun passes to its Task; used as `$(params.<name>)` |
| Result (`results`) | A small named output a step writes to `$(results.<name>.path)`; Tekton copies it to `status.results` |
| tekton-pipelines-controller | The controller that turns TaskRuns into pods and keeps their status up to date |
| tekton-pipelines-webhook | The admission webhook that sets defaults on and validates Tekton objects when they are created |
| Entrypoint binary | A Tekton program that replaces each step's command and starts the step only after the step before it finished |
| `Succeeded` condition | The status condition of a TaskRun: `Unknown` while it runs, `True` or `False` when it ends |
| Resolver | A component in `tekton-pipelines-resolvers` that fetches a Task from Git, a bundle, Artifact Hub, a URL or another namespace |
| `config-defaults` / `feature-flags` | ConfigMaps in `tekton-pipelines` that set default values / switch features on and off |
| Tekton Dashboard | A web interface for Tekton objects; read-only (`release.yaml`) or read/write (`release-full.yaml`) |
| `tkn` | The Tekton command-line tool; a client of the Kubernetes API that uses your kubeconfig |
| Kubeconfig context | A named pair of cluster and user, with an optional default namespace, in the kubeconfig file |

A `Task` and a `TaskRun` are the most confused pair. On first use in a file,
always say which one you mean, and say that the pod belongs to the TaskRun.

### The example workloads

| Name | Image | What it is |
| --- | --- | --- |
| Namespace `starfleet` | | Where every Task and TaskRun of the course runs |
| Namespace `default` | | Holds a decoy copy of a Task in some labs, to test `-n` |
| Task `hello` | `busybox:1.37.0` | Hello-world Task with the parameter `crew` and the result `greeting` |
| Task `preflight` | `busybox:1.37.0` | Two steps (`collect`, `verify`) that share files through `/workspace` |
| Task `inspect` | `busybox:1.37.0` | Three steps (`scan`, `summarize`, `report`) used by the section 010 capstone |
| Task `install-check` / `smoke` | `busybox:1.37.0` | One-step Tasks that prove an installation works |
| Task `deploy-check` | `busybox:1.37.0` | Two parameters (`crew`, `deck`), used by the section 030 capstone |
| Parameter values `bridge`, `scout`, `shuttle`, `probe` | | Crew names passed to the Tasks |

Every step uses a `script`, never a bare image without `command`: without a
command, the controller asks the registry for the image's entrypoint, which
needs the network even when the image is preloaded on the node.

### Environment facts the text must respect

- **Install from the release manifest.** Pipelines:
  `kubectl apply -f https://infra.tekton.dev/tekton-releases/pipeline/previous/v1.17.1/release.yaml`.
  Dashboard read-only:
  `kubectl apply -f https://infra.tekton.dev/tekton-releases/dashboard/previous/v0.73.0/release.yaml`;
  read/write: the same folder, `release-full.yaml`.
- **What the Pipelines release creates (checked in the v1.17.1 manifest):**
  namespaces `tekton-pipelines` (label
  `pod-security.kubernetes.io/enforce: restricted`) and
  `tekton-pipelines-resolvers`; Deployments `tekton-pipelines-controller`,
  `tekton-pipelines-webhook`, `tekton-events-controller` (in
  `tekton-pipelines`) and `tekton-pipelines-remote-resolvers` (in
  `tekton-pipelines-resolvers`); CRDs `tasks`, `taskruns`, `pipelines`,
  `pipelineruns` (`tekton.dev/v1`, also served as `v1beta1`), `stepactions`,
  `customruns` (`v1beta1`), `verificationpolicies` (`v1alpha1`) and
  `resolutionrequests.resolution.tekton.dev`; ConfigMaps `config-defaults`,
  `feature-flags`, `pipelines-info` (key `version`) and others.
- **Defaults to know:** `config-defaults` ships only an `_example` key, so the
  built-in defaults apply: `default-timeout-minutes` 60,
  `default-service-account` `default`. The webhook writes the defaults into
  `spec.timeout` and `spec.serviceAccountName` when a TaskRun is created, so a
  change only affects TaskRuns created after it. `feature-flags` ships with
  `enable-api-fields: "beta"`, `enable-step-actions: "true"`,
  `results-from: "termination-message"`, `set-security-context: "true"` (only
  for containers Tekton injects, not for steps).
- **The pod of a TaskRun:** named `<taskrun>-pod`, label
  `tekton.dev/taskRun=<taskrun>` (and `tekton.dev/task=<task>` for a
  referenced Task). Init containers `prepare` and `place-scripts`; one
  container `step-<name>` per step. Shared `emptyDir` volumes: `/workspace`,
  `/tekton/home`, `/tekton/results`, `/tekton/steps`; `/tekton/run/<n>` per
  step. `/tmp` is **not** shared between steps. Results travel through the
  container termination message (4096 bytes per pod at most).
- **Failure reasons (checked in the v1.17.1 source):** a step with a
  non-zero exit code gives `StepFailed` (not `Failed`; `Failed` is the
  fallback for other pod failures); a missing parameter gives
  `TaskRunValidationFailed`; a Task that cannot be fetched gives
  `TaskRunResolutionFailed`. The `spec` of a started TaskRun cannot change
  (the webhook rejects it); retry by creating a new TaskRun. TaskRuns are not
  owned by their Task, so deleting a Task leaves its runs.
- **Dashboard (checked in the v0.73.0 manifest):** Deployment and Service
  `tekton-dashboard` in `tekton-pipelines`, port `9097`, ConfigMap
  `dashboard-info`. The read-only release runs `--read-only=true`; the full
  release runs `--read-only=false` and adds the ClusterRoleBindings
  `tekton-dashboard-backend-edit`, `tekton-dashboard-pipelines-edit` and
  `tekton-dashboard-triggers-edit` (and a `tekton-dashboard` namespace).
  `GET /v1/properties` returns JSON with `dashboardVersion`,
  `pipelinesVersion` and `isReadOnly`. Graders read it through the API server
  proxy: `kubectl get --raw /api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/v1/properties`.
  The reader opens it with
  `kubectl -n tekton-pipelines port-forward svc/tekton-dashboard 9097:9097`
  and `http://localhost:9097`.
- **tkn has no context commands of its own.** It reads the kubeconfig like
  `kubectl`: `-k/--kubeconfig`, `-c/--context`, `-n/--namespace` (default: the
  context's namespace). "Context management" in this course means kubeconfig
  contexts (`kubectl config get-contexts`, `use-context`, `set-context
  --namespace`) and the `tkn` flags. `tkn version` prints the client version
  and reads `pipelines-info` / `dashboard-info` for the cluster versions;
  `--component client|pipeline|dashboard|triggers|chains` prints one.
- **tkn on the reader's machine.** Playgrounds and labs install `tkn` 0.46.2
  from the GitHub release tarball (`tkn_0.46.2_Darwin_all.tar.gz`,
  `tkn_0.46.2_Linux_x86_64.tar.gz`, `tkn_0.46.2_Linux_aarch64.tar.gz`) into
  `/usr/local/bin` or `~/.local/bin`, the same way for every environment.
- **The webhook must answer before Tasks are applied.** Bootstrap scripts wait
  for the rollout, then retry a server-side dry run of a small Task until the
  webhook accepts it.
- **Many environments start broken on purpose.** A lab seeds a fault (a wrong
  parameter name, a file in `/tmp`, a missing ServiceAccount, a changed
  default, a scaled-down controller). The fault is the material. Never "fix"
  it in the bootstrap.
- **The proof is a TaskRun.** A fix is proven with a TaskRun whose
  `Succeeded` condition is `True`, its results, and its pod. Graders also
  create their own TaskRun (`generateName`) to test behaviour, and delete it
  afterwards.

### Where things are in this repo

| What | Where |
| --- | --- |
| Course outline the platform reads: every reading page and lab, in order. Never list `solution.md` here | `astrona.yaml` |
| Overview, sections and modules tables, how to run things | `README.md` |
| Introduction (see "Every course starts with an Introduction") | `sections/intro/` |
| Section overview and its modules | `sections/section-0N0/README.md` |
| Module reading: landing page, deep-dive parts, closing page | `sections/section-0N0/module-0M/course.md`, `course-0N-*.md` |
| Graded lab: task, walkthrough, setup, grader | `.../labs/lab-01/` (`question.md`, `solution.md`, `prerequisites.md`, `bootstrap/`, `manifests/`, `solution/`, `testing/`, `validation/`) |
| Ungraded sandbox for a module | `.../playground/` (`config.yaml`, `bootstrap/prepare.sh`, `manifests/`, `docs/overview.md`, which is the only learner page) |
| One graded integration lab per section | `sections/section-0N0/capstone/labs/lab-01/` |

A lab folder holds:

| Path | Purpose |
| --- | --- |
| `config.yaml` | Lab definition; `metadata.docs` points at `question.md` and `solution.md` |
| `README.md` | Short intro for authors with `estimated_duration` front matter and the run, submit and destroy commands |
| `prerequisites.md` | What the learner needs before starting |
| `question.md` | The task. Starts with `# Question` and `Solve this question on: \`terminal\`` |
| `solution.md` | Step-by-step walkthrough |
| `bootstrap/01-install-tekton.sh`, `02-seed-state.sh` | The tkn CLI, Tekton Pipelines (and the Dashboard where the lab starts with it), and the starting state |
| `manifests/` | `lab-start.yaml` (namespace `starfleet`) and the seeded Tasks and TaskRuns |
| `solution/apply.sh` | Reference end state, applied only by `astrona test` |
| `testing/wait-for-tekton.sh` | Waits until the Tekton Deployments answer before the reference solution runs |
| `validation/validate-*.sh` | Behavioural grading, one script per check |

### Lab metadata in `astrona.yaml`

`astrona.yaml` has a `training:` block (id `ATS124`, domain
`Fundamentals, Architecture & tkn CLI`, weight `10`) and one entry per
section under `modules:` (`module-010`, `module-020`, `module-030`). Each
section's `content` lists, in order: the section `README.md`, then for each
module its landing page, its parts, and right after the part a lab tests, a
`Question` reading (`labs/lab-01/question.md`) followed by the `type: lab`
entry; the module's closing page comes last. The section capstone closes the
section. Playgrounds are not listed.

Every `type: lab` entry carries the same fields, in the same order, as in
ATS016: `title`, `path`, `difficulty`, `estimated_duration`, `topic`,
`task_kind`, `tags`, `learning_goals`, `resources`.

- `difficulty`: `beginner`, `intermediate` or `advanced`.
- `estimated_duration`: realistic time to solve it, for example `15m`, `30m`.
- `topic`: exactly one of `execution-model`, `architecture`, `installation`,
  `configuration`, `cli`.
- `task_kind`: exactly one of `build`, `troubleshooting` or `migration`.
- `tags`: 4 to 8 ids, only from the tag list below. Add a new tag to the list
  first if nothing fits.
- `learning_goals`: 2 or 3 plain sentences, each starting with a verb.
- `resources`: 1 to 4 pages on `tekton.dev`, each with a `name` and a `url`
  that loads. This is the **only** place outside links are allowed.

**Tag list** (lower case, hyphens, never synonyms):

- Execution model: `task`, `taskrun`, `step`, `pod-per-taskrun`,
  `entrypoint`, `params`, `results`, `workspace-dir`, `status-conditions`,
  `serviceaccount`
- Architecture: `crds`, `pipelines-controller`, `webhook`,
  `remote-resolvers`, `stepaction`, `ecosystem`
- Installation: `release-manifest`, `config-defaults`, `feature-flags`,
  `dashboard`, `read-only-dashboard`, `rbac`
- CLI: `tkn`, `tkn-task-start`, `tkn-taskrun-logs`, `tkn-taskrun-describe`,
  `tkn-taskrun-delete`, `tkn-version`, `namespaces`, `kubeconfig-context`

### Running things

```bash
# Playground (ungraded)
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-010/module-01/playground
astrona destroy ats-124-playground-010-01   # takes metadata.name from config.yaml, not the path

# Lab or capstone (graded against the live cluster)
astrona run --git ssh://git@github.com/astrona-io/ATS124.git -c sections/section-010/module-01/labs/lab-01
astrona submit -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-124-lab-010-01

# Authors: run a local, uncommitted copy, and prove a lab passes with its reference solution
astrona run -c sections/section-010/module-01/playground
astrona test -c sections/section-010/module-01/labs/lab-01
```

Names: a playground is `ats-124-playground-<section>-<module>`, a module lab
is `ats-124-lab-<section>-<module>` and a capstone is
`ats-124-capstone-<section>`; keep those names. Lab bootstrap scripts do not
pin a kube context: astrona sets `KUBECONFIG` for the lab. Every lab must pass
`astrona validate` and `astrona test`.

Graders check **behaviour**, not just that an object exists: a TaskRun with
`Succeeded` `True`, the expected result values, the right steps in the right
order, and a fresh TaskRun created by the grader that picks up the right
defaults. Graders also reject the plausible but wrong fix (an inline
`taskSpec` instead of the Task, merging steps into one, creating the missing
ServiceAccount instead of fixing the default, installing the read/write
Dashboard, running in the wrong namespace, deleting every TaskRun). A lab's
`question.md` and `solution.md` must match what its `validation/` scripts
actually check.

Test clusters on the maintainer's machine: one at a time. Each environment
runs four Tekton Deployments, plus the Dashboard where it is installed. No
script uses a fixed host port.

### Where to find trusted sources

Check facts here before writing them down. Prefer these over memory.

- **Concepts:** [overview](https://tekton.dev/docs/concepts/overview/),
  [concept model](https://tekton.dev/docs/concepts/concept-model/)
- **Installation:** [install Pipelines](https://tekton.dev/docs/installation/pipelines/),
  [additional configuration](https://tekton.dev/docs/pipelines/additional-configs/),
  [install the Dashboard](https://tekton.dev/docs/dashboard/install/)
- **APIs:** [Tasks](https://tekton.dev/docs/pipelines/tasks/),
  [TaskRuns](https://tekton.dev/docs/pipelines/taskruns/),
  [StepActions](https://tekton.dev/docs/pipelines/stepactions/),
  [container contract](https://tekton.dev/docs/pipelines/container-contract/)
- **Internals:** `docs/developers/taskruns.md` in `tektoncd/pipeline` (entrypoint, `/tekton` directories)
- **CLI:** [tkn](https://tekton.dev/docs/cli/) and `docs/cmd/` in `tektoncd/cli` at `v0.46.2`
- **The landscape:** Tekton's page on the CNCF site,
  <https://www.cncf.io/projects/tekton/> (incubating, accepted 13 March 2026),
  and the CD Foundation announcement "Tekton moves to the CNCF" (24 March 2026).

### Skills to use here

The `astrona-course-*` skills do most authoring jobs in this repository:
planning (`domain-plan`), creating the tree (`domain-scaffold`), building
modules (`domain-build`), deep-dive parts (`deep-dive`), labs and playgrounds
(`lab`), lab docs (`lab-docs`), challenges (`create-challenge`), quizzes
(`generate-assessment`) and fact-checking (`review-accuracy`).
