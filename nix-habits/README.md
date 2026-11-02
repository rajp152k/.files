# Nix habits

## Neovim dependencies (2026-10-31)

The stowed configuration is `~/.files/nvim/.config/nvim`. Neovim uses
`vim.pack`, Mason, and nvim-treesitter to install plugins, language servers,
and syntax parsers. Install their host dependencies through the pinned
NixOS configuration.

Startup diagnostics showed missing `cc`, `make`, `unzip`, `go`, `node`,
`npm`, Java, and Python. Treesitter downloads succeeded but parser compilation
failed because `cc` was absent. Mason's npm/Go installers failed before they
could run. Existing Lua, Markdown, and Rust servers exited through NixOS's
stub dynamic loader. Agentic's configured `omp acp` executable was also absent.

### System module

`neovim-dependencies.nix` contains the reproducible package declaration:

| Dependency | Purpose |
| --- | --- |
| GCC, GNU Make, tree-sitter CLI, archive/download tools | Install plugins, generate parsers, and build Telescope's native matcher |
| Git, ripgrep, fd | Git integration, project searches, and virtual-environment discovery |
| Go, Node.js/npm | Build gopls and install/run JavaScript-based language servers |
| JDK 25, Python with pip/pynvim/IPython | Run JDTLS, provide Python integration, and run Iron's Python REPL |
| SBCL with SQLite/OpenSSL, tmux, Perl/shasum | Run the persistent Common Lisp image and swank-lsp backend |
| Clojure CLI, clojure-lsp, Babashka | Run Clojure projects, provide navigation, and start Conjure's default auto-REPL |
| Rust compiler, Cargo, matching library source | Supply rust-analyzer's toolchain and standard-library navigation |
| Flutter | Supply Flutter and the `dart language-server` command |
| nix-ld with ICU and libuuid | Run Mason's generic Linux binaries with NixOS libraries |
| ImageMagick | Process Markdown images with the configured `magick_cli` backend |
| Mermaid CLI, PlantUML, D2, gnuplot | Render diagram.nvim's supported fenced diagrams |
| pylatexenc and the latex parser | Render Markdown mathematics with `latex2text` |
| xclip | X11 clipboard support, including Agentic image paste |
| OMP 18.14.0 | Retain the checksummed standalone command installed during the initial setup |

The module is installed as `/etc/nixos/neovim-dependencies.nix` and imported
from `/etc/nixos/configuration.nix`. The original configuration was backed up
as `/etc/nixos/configuration.nix.before-neovim-20261031`.

To deploy a later revision:

```sh
doas install -m 0644 ~/.files/nix-habits/*.nix /etc/nixos/
doas nixos-rebuild switch --flake /etc/nixos#tbmocwi --no-update-lock-file
```

For a new machine, add `./neovim-dependencies.nix` to the NixOS module's
`imports` before rebuilding. Use `doas` for privileged operations. Preserve
the system flake lock when deploying dependency-only changes.

The installed JDTLS 1.63.0 launcher accepts Java 21, but its Eclipse
filesystem/resources bundles require Java 25. A real Java-buffer test
identified that mismatch in the Equinox log; the module therefore uses
`jdk25`.

The module also sets `RUST_SRC_PATH` to the matching Nix Rust library source.
Refresh the current shell's system environment after activation:

```sh
. /etc/set-environment
```

A fresh login also supplies the setting. NixOS guards profile initialization
with `__NIXOS_SET_ENVIRONMENT_DONE`, so a child login shell can inherit the
previous environment until it is refreshed.

### OMP package

`omp.nix` packages the upstream Linux x64 standalone binary with its Bun
runtime embedded. The release digest published by GitHub matches the download:

```text
Version: 18.14.0
SHA-256: e7dd2b606c4ebe9d1a7bcfad1b8820db968cd6b05409fed1c6bc8db0b6a95a8f
```

The package retains the embedded payload and uses the module's nix-ld
compatibility. The upstream
[Nix and standalone installation documentation](https://github.com/can1357/oh-my-pi)
also describes installation options. Authentication is configured separately
in OMP. After the dotfiles pull, Agentic invokes
`autolith --permissions full acp` from the existing user Nix profile instead.

### D2 PNG rendering

The pinned D2 0.7.1 package tried to download its Playwright 1.47.2 driver
from retired CDN endpoints and failed with HTTP 404. `d2.nix` overrides the
package to supply the checksummed npm `playwright-core` 1.47.2 driver and
Nix's Node.js and Chromium. The wrapper supplies `PLAYWRIGHT_DRIVER_PATH`
and `PLAYWRIGHT_NODEJS_PATH`; the source override selects Chromium explicitly
and skips browser installation.

The override passed D2's build tests and rendered PNG and SVG files. A second
PNG render with a fresh home/cache and an unreachable download endpoint also
succeeded. Review the driver version and substitutions when upgrading D2.

### Provision editor-managed dependencies

After activating the system configuration, run in Neovim:

```vim
:MasonToolsInstallSync
:TSInstall bash c clojure commonlisp css dart diff html javascript json latex lua luadoc markdown markdown_inline python query scss tsx typescript toml vim vimdoc yaml
:checkhealth kickstart mason nvim-treesitter vim.lsp telescope render-markdown agentic
```

Wait for installations to finish. Mason manages all ten packages declared in
`lua/kickstart/plugins/lspconfig.lua`; Flutter supplies Dart separately.
Treesitter also installs language parsers when opening other filetypes.

The existing Telescope native matcher had been downloaded without compiling
its shared library. Rebuilt it after installing GCC and Make:

```sh
make -C ~/.local/share/nvim/site/pack/core/opt/telescope-fzf-native.nvim
```

Future plugin installs/updates use the existing `PackChanged` build hook.


### Latest dotfiles and development runtimes

Fetched and merged `origin/master` at `b1700dc`, incorporating 39 upstream
commits. Merge commit `6c4ccab` preserves the local Nix setup and combines the
new Clojure/Common Lisp/Python parser declarations with the latex parser.

The pull added Vlime, swank-lsp, nvim-paredit, Conjure, Iron, and
venv-selector. Install them through the configured `vim.pack` declarations.
The updated Agentic provider invokes the installed Autolith CLI.

#### Common Lisp

After the NixOS rebuild and Neovim plugin installation, provision the backend:

```sh
sbcl --script ~/.files/nix-habits/setup-common-lisp.lisp
```

The helper installs Quicklisp at `~/quicklisp` when absent, checks the bootstrap
against the [published SHA-256](https://www.quicklisp.org/beta/), and selects the
2026-01-01 distribution for a new installation. Existing Quicklisp settings are
used without an upgrade. It checks out the three exact backend commits listed
in `~/.config/nvim/doc/common-lisp.md` under
`${XDG_DATA_HOME:-$HOME/.local/share}/common-lisp`, and loads swank-lsp and Vlime.
An existing modified checkout or a different revision requires inspection
before provisioning.

The Lisp backends load SQLite and OpenSSL through CFFI. The module wraps SBCL
with a process-local `LD_LIBRARY_PATH` containing both libraries. A real
launcher test caught OpenSSL's absence in the tmux image's environment.

In a Lisp project, use `:LispStart [asdf-system]`, `:LispConnect`, and
`:LispStop`. Both Vlime and the native LSP connect to that project's one SBCL
image. Follow `:LispHelp` for evaluation, inspection, and structural editing.

#### Clojure

The module supplies `clojure`, `clojure-lsp`, and Babashka (`bb`). clojure-lsp is
intentionally outside Mason. Conjure's default auto-REPL starts
`bb nrepl-server` when no project nREPL is available. For a JVM project, start
its own nREPL with the project's dependencies and connect through
`.nrepl-port`. Keep dependencies in `deps.edn` or the project's build
configuration. See `~/.config/nvim/doc/clojure.md` for navigation and REPL keys.

The pinned Conjure revision passes `ConjureProcessOnExit` to `termopen` as a
Vimscript callback but defines only a user command with that name. The small
adapter in `lua/custom/plugins/clojure.lua` delegates the callback to Conjure's
own cleanup function. REPL evaluation and shutdown were tested together.

#### Python

The system Python includes IPython for Iron. For a project environment that
also uses the Nix-provided Python packages:

```sh
python3 -m venv --system-site-packages .venv
```

Use `<Space>pv` to select the environment and `<Space>pr` to open its IPython
REPL. Independent environments need their own IPython installation. Mason
manages Pyright.

### Stow

This directory is a reference package. Its `.stow-local-ignore` contains
`.*`, so every entry is ignored, including when explicitly running
`stow nix-habits` or including it in `stow */`.

Check the proposed actions with:

```sh
stow --simulate --verbose=3 --dir="$HOME/.files" --target="$HOME" nix-habits
```

### Initial verification, before the pull

- NixOS rebuild and activation succeeded; deployed Nix files match this directory.
- Neovim started in a sized pseudo-terminal with no Vim errors.
- All ten Mason packages are installed, and all 25 installed Treesitter parsers load.
  Added the latex parser to the declarative list; Go, Java, Python, and Rust were
  also installed while checking their buffers.
- All eleven configured language servers initialized in representative project
  buffers. Document-symbol requests succeeded where supported. Java required
  the verified JDK 25 correction. The ESLint fixture checked server initialization;
  actual projects supply their own ESLint package and rules.
- Telescope's compiled native matcher loaded successfully.
- OMP answered an ACP initialize request with protocol version 1.
- Mermaid, PlantUML, D2, and gnuplot produced valid, visually inspected PNGs;
  `latex2text` converted a sample formula.
- Stow's dry run proposed no links for `nix-habits`.

Graphics checks covered generated PNGs; in-terminal image display and clipboard
transfer depend on the graphical session. Health checks can show informational
warnings for optional ACP providers, unused runtimes, and icon plugins.


### Verification after the pull

- NixOS rebuilt and activated with the new runtimes; deployed Nix modules match
  this directory. The Common Lisp provisioning helper also passed repeatedly
  with process-specific ASDF and library-path settings removed.
- Sized-terminal startup passed. All 22 Lua files passed syntax checks, along
  with the Nix module and shell launcher.
- All six new plugins were installed, all 27 installed parsers load, and all
  ten Mason packages are installed. Scoped dependency health checks report no errors.
- Python buffers attached to Pyright. Iron evaluated code in system IPython
  and a virtualenv activated through venv-selector.
- Clojure CLI evaluated a sample expression. clojure-lsp returned document
  symbols and definitions; Conjure's Babashka auto-REPL evaluated code and stopped
  without the previous callback error.
- A project ASDF system loaded in the tmux-hosted SBCL image. Vlime evaluated
  code after its SWANK-REPL initialization, and swank-lsp returned a definition.
  The test image was stopped afterward.
- Autolith answered ACP initialization with protocol version 1, without a
  session or inference request.
- Stow's dry run proposed no links, including for the provisioning helper.
