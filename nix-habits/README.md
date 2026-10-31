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
| GCC, GNU Make, unzip | Compile Treesitter parsers and Telescope's native matcher; unpack Mason archives |
| Go, Node.js/npm | Build gopls and install/run JavaScript-based language servers |
| JDK 25, Python with pip/pynvim | Run JDTLS and its Python launcher; provide Python integration |
| Rust compiler, Cargo, matching library source | Supply rust-analyzer's toolchain and standard-library navigation |
| Flutter | Supply Flutter and the `dart language-server` command |
| nix-ld with ICU and libuuid | Run Mason's generic Linux binaries with NixOS libraries |
| ImageMagick | Process Markdown images with the configured `magick_cli` backend |
| Mermaid CLI, PlantUML, D2, gnuplot | Render diagram.nvim's supported fenced diagrams |
| pylatexenc and the latex parser | Render Markdown mathematics with `latex2text` |
| xclip | X11 clipboard support, including Agentic image paste |
| OMP 18.14.0 | Supply Agentic's `omp acp` provider from a checksummed standalone release |

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
compatibility. Agentic invokes `omp acp` through the system PATH. The upstream
[Nix and standalone installation documentation](https://github.com/can1357/oh-my-pi)
also describes installation options. Authentication is configured separately
in OMP.

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
:TSInstall bash c css dart diff html javascript json latex lua luadoc markdown markdown_inline query scss tsx typescript toml vim vimdoc yaml
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

### Stow

This directory is a reference package. Its `.stow-local-ignore` contains
`.*`, so every entry is ignored, including when explicitly running
`stow nix-habits` or including it in `stow */`.

Check the proposed actions with:

```sh
stow --simulate --verbose=3 --dir="$HOME/.files" --target="$HOME" nix-habits
```


### Verification

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
