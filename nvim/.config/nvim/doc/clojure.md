# Clojure in Neovim

`clojure-lsp` provides navigation, workspace symbols, diagnostics, and code actions. The configuration uses the system `clojure-lsp` executable and the `clojure` Tree-sitter parser. On NixOS, `~/.files/nix-habits/neovim-dependencies.nix` supplies Clojure CLI and clojure-lsp. On macOS, install them with Homebrew.

## Navigation

| Key | Action |
| --- | --- |
| `grd` | Go to definition |
| `grr` | Find references |
| `gO` | Find document symbols |
| `gW` | Find workspace symbols |
| `<Space>sf` | Find files |
| `<Space>sg` | Search project text |

These LSP keys are buffer-local and appear when the server attaches. Start Neovim in a Clojure project with a `deps.edn`, `project.clj`, `build.boot`, `shadow-cljs.edn`, `bb.edn`, or `.git` root.

## REPL and structural editing

Conjure provides interactive evaluation. Its default auto-REPL uses Babashka (`bb nrepl-server`), included in the NixOS module. For a JVM project, start its own nREPL with the project's dependencies and connect through `.nrepl-port`. Press `<Space>ee` to evaluate the form under the cursor. Run `:ConjureSchool` for the interactive guide. Read `:help conjure-client-clojure-nrepl` for the Clojure client mappings.

The existing paredit mappings also apply in Clojure buffers: `<` and `>` move list boundaries; `af` / `if` select a form; `aF` / `iF` select a top-level form; `]e` / `[e` move between elements. Delimiter and quote pairs are enabled in insert mode.

The LSP executable is not managed by Mason. Check it with `clojure-lsp --version`. After opening a project, use `:checkhealth vim.lsp` to inspect server attachment.
