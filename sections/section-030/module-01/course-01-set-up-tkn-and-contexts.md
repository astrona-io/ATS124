# Set Up tkn And Choose The Cluster And Namespace

Most people who work with Tekton have access to more than one cluster, and every cluster has many namespaces. A command-line tool that starts work has to know exactly where to start it. `tkn` does not keep its own list of clusters; it uses the same kubeconfig file and the same rules as `kubectl`. This part installs `tkn`, checks it against the cluster, and shows how to control the cluster and the namespace it works in.

## Install tkn

`tkn` is one binary. Each release on GitHub publishes an archive per operating system and processor type, and the archive holds the `tkn` binary plus its license and README. Your playground already installed version 0.46.2. On your own machine, the install looks like this for Linux on an x86-64 processor:

<!-- astrona:playground:renew -->

```sh
curl -fsSLO https://github.com/tektoncd/cli/releases/download/v0.46.2/tkn_0.46.2_Linux_x86_64.tar.gz
sudo tar -xzf tkn_0.46.2_Linux_x86_64.tar.gz -C /usr/local/bin tkn
```

For Linux on ARM64 the archive is `tkn_0.46.2_Linux_aarch64.tar.gz`, and for macOS, on both Intel and Apple processors, it is `tkn_0.46.2_Darwin_all.tar.gz`. Package managers also carry `tkn`: Homebrew calls it `tektoncd-cli`, and the release has `.deb` and `.rpm` packages. Pin the version, so that the commands and flags match this course.

## Check the client and the cluster

`tkn version` prints the version of the client, and then asks the cluster which Tekton components it runs:

```sh
tkn version
```

The output lists the client version 0.46.2, the Pipeline version v1.17.1 and the Dashboard version v0.73.0. `tkn` read the two cluster versions from the ConfigMaps `pipelines-info` and `dashboard-info` in `tekton-pipelines`. If a component is missing, its line is missing too. If the cluster cannot be reached, `tkn` still prints the client version, so a version line alone does not prove a connection.

To print only one version, for example in a script, name the component:

```sh
tkn version --component pipeline
```

It prints just `v1.17.1`. The flag also accepts `client`, `dashboard`, `triggers` and `chains`.

## How tkn picks the cluster and the namespace

`tkn` reads the kubeconfig file, the same file `kubectl` uses: the file named in the variable `KUBECONFIG`, or `~/.kube/config`. A kubeconfig file holds clusters, users and contexts. A **context** is a named pair of one cluster and one user, with an optional default namespace. One context is the current context, and every command uses it unless a flag says otherwise. List them:

```sh
kubectl config get-contexts
```

The current context has a star in the first column. Its `NAMESPACE` column is probably empty, which means `default`. Three flags of `tkn` override the kubeconfig, and they work on every `tkn` command:

| Flag | What it overrides |
| --- | --- |
| `-k`, `--kubeconfig` | The kubeconfig file to read |
| `-c`, `--context` | The context to use, instead of the current context |
| `-n`, `--namespace` | The namespace, instead of the context's default namespace |

`tkn` has no command to create or switch contexts. You manage contexts with `kubectl config`, and `tkn` follows.

## A context for the starfleet namespace

Typing `-n starfleet` on every command is easy to forget. A context with a default namespace removes that risk. Create one named `starfleet` that uses the same cluster and user as your current context:

```sh
kubectl config set-context starfleet --namespace=starfleet --cluster="$(kubectl config view --minify -o jsonpath='{.contexts[0].context.cluster}')" --user="$(kubectl config view --minify -o jsonpath='{.contexts[0].context.user}')"
```

`kubectl config view --minify` shows only the current context, so the two `jsonpath` expressions fill in its cluster and user. Use the new context for one `tkn` command, without switching:

```sh
tkn taskrun list --context starfleet
```

`tkn` answers that no TaskRuns were found. It looked in `starfleet`, because the context `starfleet` names that namespace. Without `--context`, the same command looks in `default`. To make the new context the current one for every command, run `kubectl config use-context starfleet`, and switch back later with `kubectl config use-context` and the name of the old context. To change only the namespace of the current context, `kubectl config set-context --current --namespace=starfleet` does the same in one step.

When you destroy the playground, its cluster disappears, but the context `starfleet` stays in your kubeconfig. Remove it when you no longer need it:

```sh
kubectl config delete-context starfleet
```

You can now install `tkn`, check the client and cluster versions with `tkn version`, and control where `tkn` works with kubeconfig contexts and the flags `--context`, `--kubeconfig` and `-n`. The open question is what to do once `tkn` points at the right place: start a Task.

## Common pitfalls

> [!WARNING]
> - **Looking for `tkn context` commands.** There are none. `tkn` uses the kubeconfig; manage contexts with `kubectl config`.
> - **Trusting the client version line.** `tkn version` prints it even when the cluster is unreachable. Look for the Pipeline version line.
> - **Forgetting the namespace.** Without `-n` or a context namespace, `tkn` works in `default`, where your Tasks probably are not.
> - **Leaving old contexts behind.** A context for a deleted cluster stays in the kubeconfig and fails later with connection errors. Delete it with `kubectl config delete-context`.
