# Neovim: navigation, search, and keybindings

`<Space>` is the leader key; `<C-x>` means Ctrl+x. Open Neovim from the repository root so project searches use the right directory (`nvim path/to/file`). Use `<Space>sk` to search installed keybindings and `<Space>sh` to search help when you forget a command.

## Move without leaving the keyboard

| Want to… | Press |
| --- | --- |
| Move by character or line | `h` / `j` / `k` / `l` (left / down / up / right). |
| Move by word | `w` / `b` (forward / back). |
| Move within a line | `0` (start), `^` (first nonblank), `$` (end). |
| Move through a file | `gg` (top), `G` (bottom), `<C-d>` / `<C-u>` (half page down / up). |
| Enter/leave editing | `i` to insert; `<Esc>` to return to normal mode. |
| Save/quit | `:w` / `:q` / `:wq`. |
| Switch open buffers | `<Space><Space>` for the buffer picker; `:bnext` / `:bprevious` for sequential switching. |
| Move among splits | `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>`; `:vsplit` or `:split` to open one. |

Normal mode is the starting point for the mappings below. If a key seems to insert text instead of navigating, press `<Esc>` first.

## Choose the right search

| Want to… | Press | Why |
| --- | --- | --- |
| Open a file by name | `<Space>sf` | Fuzzy file search (Telescope). |
| Find text anywhere in the project | `<Space>sg` | Live grep; requires `rg`, which is installed. |
| Find the word under the cursor | `<Space>sw` | Literal project-wide search; works without LSP. Also works on a visual selection. |
| Find text in this file | `/pattern` then `n` / `N` | Exact Vim search, next / previous occurrence. `<Esc>` clears highlights. |
| Fuzzy-search this file | `<Space>/` | Search lines of the current buffer with Telescope. |
| List functions/types in this file | `gO` | LSP document symbols; a structural outline, not a text search. |
| Find a function/type by name across the project | `gW` | LSP workspace symbols; depends on server support/indexing. |
| Find only among open buffers | `<Space><Space>` | Fuzzy buffer picker. `<Space>s.` finds recent files; `<Space>sr` resumes the last picker. |

## Follow code

Put the cursor on a name, then:

| Press | Result |
| --- | --- |
| `grd` | Definition(s), via Telescope. |
| `grr` | References/uses, via Telescope. |
| `gri` | Implementations, if the language server supports them. |
| `grt` | Type definition. |
| `K` | Hover documentation/type information in a code buffer with an attached LSP. |
| `<C-o>` / `<C-i>` | Back / forward through jumps. `<C-t>` also returns from tag-style definition jumps. |

These LSP actions use the same keys for Go (`gopls`), Java (`jdtls`), Flutter/Dart (`dartls`), and the other configured languages. They require an attached language server. Typical project markers are `go.mod`, `pom.xml`/Gradle files, and `pubspec.yaml`. If symbols are unavailable, try `<Space>sg` and check `:checkhealth vim.lsp`.

Inside a Telescope picker: type to narrow, `<CR>` opens the result, `<C-v>` opens a vertical split, `<C-x>` a horizontal split, `<C-t>` a tab, and `<C-q>` sends results to the quickfix list. `<C-/>` shows picker help.

## Diagnostics and changes

| Press | Result |
| --- | --- |
| `]d` / `[d` | Next / previous diagnostic; this config opens its details on jump. |
| `<Space>sd` | Search diagnostics in Telescope. |
| `<Space>q` | Open the diagnostic location list. |
| `<Space>gg` | Open Neogit status. `<Space>gd` diff; `<Space>gl` log; `<Space>gc` commit; `<Space>gs` stash. |
| `<Space>hp` / `<Space>hb` | Preview Git hunk / show blame in a tracked file (Gitsigns). |

`[h` / `]h` navigate Git hunks in tracked files; Markdown keeps its own `]c` for “current section heading.”

## Markdown and OMP

Markdown keeps its existing rendering, table reader, and editing helpers: `<Space>mt` toggles table reader, `<Space>mp` previews a table, `<Space>md` previews a diagram, `<Space>mx` toggles a task, and `<Space>mo` / `<Space>mO` add a list item below / above. `]]` / `[[` go to next / previous heading; `]p` goes to the parent heading.

With the cursor on an image link in Markdown, press `<Space>m+` to zoom its preview in or `<Space>m-` to zoom out. The same keys work when viewing an image file directly. Zoom affects the currently visible image; moving away from a Markdown link closes its preview.

See [Markdown in Neovim](markdown.ref.md) for the full Markdown reading, editing, table, image, and diagram workflows.

`<Space>ao` toggles OMP chat; `<Space>aa` adds the current file or visual selection as context; `<Space>an` begins a new session. Use visual selection before `<Space>aa` for a focused question about a small piece of code.

## A practical route through an unfamiliar project

1. From the project root, `<Space>sf` for a likely entry point; if you do not know its name, `<Space>sg` for a distinctive term.
2. `gO` to scan the file, or `gW` to find a named symbol across files.
3. `grd` to follow a call, `grr` to see its callers, and `<C-o>` to retrace your path.
4. When syntax or names are unclear, visually select the relevant code and press `<Space>aa`, then `<Space>ao` to ask OMP.
