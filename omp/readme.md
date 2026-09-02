# OMP

This package tracks the durable, non-secret part of the OMP agent setup:

- `.omp/agent/config.yml` — model, display, and extension registration settings.
- `.omp/agent/extensions/tmux-ready-popup.mjs` — local tmux completion notification.

Do **not** version the rest of `~/.omp`. It is runtime state: credentials, SQLite databases, sessions, traces, logs, caches, browser profiles, locks, and generated artifacts. It is both private and disposable.

## Install

The managed files must be linked into OMP's default config root (`omp config path`). For an existing machine, inspect the proposed import first:

```sh
diff -u omp/.omp/agent/config.yml ~/.omp/agent/config.yml
diff -u omp/.omp/agent/extensions/tmux-ready-popup.mjs \
  ~/.omp/agent/extensions/tmux-ready-popup.mjs
```

Then adopt only these tracked files and create the stow links:

```sh
stow --adopt --restow omp
```

`--adopt` makes the repository match any local changes to those files. Review the resulting diff before committing. On another machine, authenticate separately; authentication is intentionally not part of this package.

## Updating settings

Edit `omp/.omp/agent/config.yml`, then refresh the links:

```sh
stow --restow omp
omp config list --json
```

Avoid using `omp config set` as the normal edit path: it changes the deployed file, making configuration drift easy to miss. If it is useful interactively, adopt the result immediately and review the diff:

```sh
omp config set <key> <value>
stow --adopt --restow omp
```

## tmux notification

The extension shows a small `tmux display-popup` when an interactive OMP run completes. It does nothing outside tmux. Test it from an OMP TUI session with:

```text
/notify-test
```

The extension sanitizes the pane title and notification text before passing it to tmux. Keep it dependency-free and fail-safe: notification errors must never fail an agent run.

## Maintenance

After an OMP update, verify the managed settings still load and that the extension is registered:

```sh
omp config path
omp config list --json
```

Add a file here only when it is user-authored, deterministic, non-secret, and required to recreate the desired behavior. Keep environment-specific credentials, session history, model caches, and generated state out of version control.
