# Common Lisp in Neovim

Vlime handles evaluation, compilation, inspection and debugging. The native
`swank_lsp` client handles Telescope navigation. Both connect to one project-local
SBCL image in a detached tmux session.

## Start a project

Open a Lisp source buffer and run `:LispStart system-name` to load its ASDF system.
Use `:LispStart` or `<Space>ls` to start without loading a system. To load another
system in an existing image, press `<Space>la` and evaluate
`(ql:quickload "system-name")`.

Find the project root using `.git`, `qlfile`, or `.lisp-dev-root`, walking upward
from the source file. Without a marker, use the source file's directory. For a
multi-directory project without Git or Qlot, create `.lisp-dev-root` at its root.

After restarting Neovim, open the project's Lisp buffer to reconnect. Use
`:LispConnect` or `<Space>lc` to connect explicitly. `:LispStatus` reports the image;
`:LispStop` or `<Space>lq` stops it. SBCL outlives Neovim. Stop the image explicitly
when you no longer need its state.

Open the console with `:LispConsole` or `<Space>lr`; detach with your tmux prefix
followed by `d` (currently `<C-Space>d`). Closing the console view does not stop the image. From a separate terminal,
use `~/.config/nvim/scripts/lisp-dev start "$PWD" system-name`. The launcher also
accepts `stop`, `status`, and `console` in place of `start`.

## Source-buffer keys

| Key | Action |
| --- | --- |
| `<Space>l?` | Open this reference (`:LispHelp`) |
| `<Space>ls` / `<Space>lc` | Start image / connect |
| `<Space>lq` / `<Space>lr` | Stop image / open SBCL console |
| `<Space>le` | Evaluate form/atom, or visual selection |
| `<Space>lt` | Evaluate top-level form |
| `<Space>lb` | Compile and redefine top-level form |
| `<Space>lf` | Save, compile and load current file |
| `<Space>la` | Open evaluation input |
| `<Space>li` | Inspect the form's result |
| `<Space>lm` | Macroexpand once |
| `<Space>ld` | Describe symbol |
| `<Space>lh` | Function argument signature |
| `<Space>lx` | Find callers through Swank |
| `<Space>lg` | Find definition through Swank |
| `<Space>lp` | Raise form |
| `<C-x><C-o>` in insert mode | Manual image-based completion |

Use existing `grd` and `grr` Telescope bindings for LSP definitions and references;
`K` opens hover documentation. The backend does not implement document/workspace
symbols, diagnostics, formatting, or code actions. Use Telescope file/grep searches
for unloaded source. Runtime references require loading/compiling the relevant
code and are not a complete static repository index. Vlime selects the evaluation
package from the buffer's `in-package` form.

## Structural editing

Use `>)` / `<(` to slurp forward/backward and `<)` / `>(` to barf forward/backward.
Use `af` / `if` for the enclosing form and `aF` / `iF` for the top-level form.
These are Lisp-buffer mappings. Ordinary word motions are unchanged.

## Debugger and inspector

An unhandled condition opens Vlime's debugger. Move to a restart and press
`<Enter>` to invoke it. Press `<Enter>` on a stack frame to inspect its details.
In the inspector, press `<Enter>` on a field to inspect it. Press `<Space>lv?`
in a Vlime UI buffer to display that buffer's keys. See `:help vlime` for details.

## Installed runtime

- Homebrew SBCL, with ASDF.
- Quicklisp at `~/quicklisp`, loaded explicitly by the launcher.
- Backend checkouts under `~/.local/share/common-lisp`: `ramfjord/swank-lsp` at
  `20b04439b2ecd82c33d1b65f3a43c3a27b906c62`, `ramfjord/cl-scope-resolver` at
  `b8a137c420d37ad4b2eecf529a29864b07328cde`, and `ramfjord/jsonrpc` at
  `53caf42cb3d4afabb84a3869505d16d25c423895`.
- Neovim plugins in `nvim-pack-lock.json`, plus the `commonlisp` parser.

Use the provisioned JSON-RPC checkout: the backend requires its patched byte-counted
transport rather than Quicklisp's ordinary `jsonrpc`. All development listeners bind
to `127.0.0.1`. Port files and startup logs are in
`${XDG_CACHE_HOME:-~/.cache}/nvim/common-lisp/<project-path-sha256>/`.

Config: `lua/custom/plugins/common-lisp.lua`. Image startup: `scripts/lisp-dev`
and `scripts/lisp-dev.lisp`. Read the image's `startup.log` if startup fails.
