# Autolith

This Stow package stores portable Autolith configuration in `.config/autolith/`.
`init.lisp` sets the model, reasoning effort, reasoning traces, and Simple
Technical English. It imports the saved settings from this machine.

## Install

Install Autolith and authenticate its provider. From `~/.files`, run:

```sh
stow --simulate --verbose --no-folding --target="$HOME" autolith
stow --no-folding --target="$HOME" autolith
```

Use `--no-folding` to link files individually. Keep the destination directories
real so Autolith can create local files there. If a managed file already exists,
compare it with the repository copy before moving it aside or adopting it.

Start a new Autolith process to load the configuration. This package was tested
with Autolith 0.58.0. The selected model requires an available provider.

## Operational log skill

The `ops-log` skill adapts the OMP skill for raj's blog. It covers requested logs,
STE prose, local review, and separate approval for commit and publication.

Autolith rejects skill symlinks that resolve outside its skill root. Stow excludes
`skills/`. From `~/.files`, install the tracked skill as a regular file:

```sh
install -d "$HOME/.config/autolith/skills/ops-log"
install -m 644 autolith/.config/autolith/skills/ops-log/SKILL.md \
  "$HOME/.config/autolith/skills/ops-log/SKILL.md"
```

After each skill edit, repeat the install command. Use `/skills` to check discovery.
Autolith refreshes the skill catalog on the next model request; no restart is needed.

## Change settings

Edit `.config/autolith/init.lisp` and start a new process. Changes through
`/settings` update local saved preferences; also update this file when you want
the change on other machines. Initialization applies the settings in this file.

For machine-specific settings, create `~/.config/autolith/local.lisp`. The init
file loads it after the portable settings. Git and Stow exclude this local file.
Use the same `(setf (config :setting-name) value)` forms there.

## Extend the setup

Add `mcp.sexp`, `lsp.sexp`, `agents/`, `skills/`, or Lisp source in `extensions/`
when needed. Load Lisp extensions explicitly from `init.lisp`. Install external
server programs separately and document them here. Keep credentials in local
files or provider authentication storage.

Git permits only the configuration paths listed in `.gitignore`. Review every
new file before adding it. Conversations, memories, agendas, private runtime
commits, and generated preferences use Autolith's separate data and state roots.
