# Markdown in Neovim

Open a `.md` file with Neovim from the project directory (`nvim notes.md`). `<Space>` is the leader key. This guide covers the Markdown-specific behavior of the current configuration; see [Neovim navigation and search](neovim-navigation.ref.md) for general movement, Telescope, Git, and keybinding discovery.

## Read and inspect

- Markdown has wrapped prose, line breaks at words, spelling enabled, and heading/code-fence folds. `]s` / `[s` visit misspellings; `z=` suggests corrections. Folds begin open: `zc` closes, `zo` opens, `za` toggles, `zM` closes all, `zR` opens all.
- `render-markdown.nvim` decorates headings, code blocks, lists, and checkboxes in the editor; its configured checkbox forms include `[ ]`, `[x]`, and `[-]`. It does **not** own pipe-table rendering here. `:RenderMarkdown buf_toggle` toggles its decorations for the current buffer when you need to inspect raw markup. That command does not switch the separate table Reader off; use `<Space>mt` for that.
- Treesitter provides syntax highlighting. `marksman` supplies Markdown LSP support where attached; `gO` shows document symbols, `grd` definitions, `grr` references, and `K` hover when supported. `<Space>sf` finds files, `<Space>sg` searches project text, and `<Space>sw` searches the word/selection under the cursor without relying on LSP.

### Move through headings

| Key or command | Action |
| --- | --- |
| `]]` / `[[` | Next / previous heading. |
| `]c` / `]p` | Current section heading / parent heading. |
| `:MDToc` | Open a heading outline in the location list; choose a heading to jump. |
| `:MDInsertToc` | Insert a Markdown table of contents into the **document** at the cursor; inspect the edit before saving. |

## Write and edit

### Inline styles and links

`markdown.nvim` provides style keys `i` (italic/emphasis), `b` (bold/strong), `s` (strikethrough), and `c` (inline code):

| Action | Example |
| --- | --- |
| Toggle style over a motion | `gsiwb` makes the word under the cursor bold; `gsiwi` toggles italic. |
| Toggle style over a visual selection | Select text, then `gsb` for bold or `gsc` for code. |
| Toggle style over the current line | `gssb` for bold. |
| Remove/change style surrounding the cursor | `dsb` removes bold; `csbi` changes bold to italic. |
| Add a link | `gliw` over a word, or select text and press `gl`. |
| Follow a Markdown link | `gx` opens local files/headings or a web URL. |

You can also select text and paste a URL from the system clipboard to turn it into a Markdown link. The style/link operations apply to appropriate inline content rather than indiscriminately wrapping list markers or blank lines.

### Lists and tasks

- On an existing list item, `<Space>mo` / `<Space>mO` adds a matching item below / above. It preserves indentation/marker and updates ordered numbering; it does nothing outside a list.
- `<Space>mx` toggles the current task checkbox; in Visual mode, it toggles tasks in the selected lines. `:MDResetListNumbering` renumbers ordered lists throughout the buffer or Visual selection.
- Checkboxes remain ordinary Markdown source, not a separate task database.

## Read and edit pipe tables

`markdown-table-wrap.nvim` uses a **Reader** view for documents with pipe tables. It opens automatically when a table is detected, wraps long cells to the window, and leaves ordinary Markdown source unchanged. The Reader is a derived, non-modifiable view; the backing `.md` file remains the source of truth.

| Key or command | Action |
| --- | --- |
| `<Space>mt` | Toggle between Reader and Source; leaving Reader pauses auto-reopen until toggled back. |
| `<Space>mp` | Open the configured table preview (Reader). |
| `:MarkdownTableEditSource` | Stay in Source for structural editing without immediate auto-reopen. |
| `:MarkdownTableHelp` / `:MarkdownTableStatus` | Show Reader actions / current rendering state. |
| `i`, `a`, `o`, `O` in Reader | Jump to the corresponding Source line to edit; Reader normally returns after Insert mode. |
| `:w` or `:wq` in Reader | Save the backing Markdown source, not the rendered scratch view. |

Inside a **rendered table cell**, `yic` yanks its raw source, `vic` selects the whole logical cell, `dic` clears its source content, and `cic` changes it in Source Insert. For copying **rendered** text, use ordinary Visual selection and `y`. The Reader deliberately guards unmatched normal-mode `y`/`d` motions such as `dd`; switch to Source for row deletion, moving rows, or editing delimiters. Native `c` motions switch to Source. `gx` in Reader follows a rendered link's original target.

For deliberate table edits, use `:MarkdownTableFormat` (rewrites the current table), `:MarkdownTableAddRow`, `:MarkdownTableDeleteRow`, `:MarkdownTableMoveRowUp` / `:MarkdownTableMoveRowDown`, `:MarkdownTableAddColumn` / `:MarkdownTableDeleteColumn`, and `:MarkdownTableToggleAlignment`. `:MarkdownTableEditCell` offers a focused cell popup (`<C-s>` commits, `<Esc>`/`q` cancels). `:MarkdownTableExport csv` or `:MarkdownTableExport tsv` copies the current table; `:MarkdownTableYankTable` copies its rendered view. Rendering alone does not reformat source tables.

## Images and diagrams

- For a **local image link**, move the cursor onto the link to see its popup preview. Only the image at the cursor is rendered; the preview clears while inserting or moving away. Remote images are not downloaded. `<Space>m+` / `<Space>m-` zoom the currently visible image; the same keys work when an image file is open directly.
- Images use the Kitty graphics protocol and ImageMagick CLI (`magick`); a compatible terminal is needed. Headless Neovim or terminals without that graphics support cannot show the image preview.
- For a fenced diagram such as `mermaid`, place the cursor **inside the code block** and press `<Space>md`. It renders on demand in a tab; `q` or `<Esc>` closes that preview. Automatic diagram rendering is disabled. Mermaid rendering uses `mmdc` with a dark theme; other supported renderer types (PlantUML, D2, gnuplot) need their respective external tools, which are not part of this setup.

## Ask about a document

Visually select a passage and press `<Space>aa` to send that selection to OMP, or press it without a selection to add the current file. `<Space>ao` toggles the chat and `<Space>an` starts a new session. This is useful for asking about a section without leaving the Markdown buffer.

If a Markdown-specific key is missing, confirm the filetype with `:set filetype?` and search mappings with `<Space>sk`. For plugin details, use `:help markdown.nvim`, `:help markdown-table-wrap`, or `:help render-markdown`.
