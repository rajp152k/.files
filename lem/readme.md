# Lem

This Stow package stores shared Lem settings in `.config/lem/init.lisp`.
Lem loads this Common Lisp file at startup.

## Install

Build Lem, then run these commands from `~/.files`:

```sh
stow --simulate --verbose --no-folding --target="$HOME" lem
stow --no-folding --target="$HOME" lem
```

Use `--no-folding` to link the init file separately. Lem writes logs, history,
and other local files in the real `~/.config/lem/` directory.

## Settings

Edit `.config/lem/init.lisp` and restart Lem.
For machine-specific settings, create `~/.config/lem/local.lisp`.
The init file loads it after the shared settings. Git and Stow exclude it.

Lem uses `LEM_HOME` when set. Otherwise, it uses `~/.lem/` if that directory
exists, or `$XDG_CONFIG_HOME/lem/` (normally `~/.config/lem/`).
Use the XDG path for this package.

## Run

On this machine, the executable is `~/common-lisp/lem/lem`.
The `lem` alias in `~/.bashrc` points to that executable.

This package was tested with Lem 2.3.0-2c882dee.
