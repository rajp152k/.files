-- Modern neutral dark theme with crisp contrast and restrained accents.

local palette = {
  bg = '#0b0d10',
  bg_dark = '#080a0c',
  bg_float = '#12161b',
  bg_highlight = '#181d23',
  bg_selection = '#293341',
  bg_yellow = '#332a16',
  bg_orange = '#352319',
  bg_green = '#172b20',
  bg_blue = '#17283d',
  bg_purple = '#2a2038',
  bg_red = '#351d20',
  fg = '#e6edf3',
  fg_bright = '#ffffff',
  fg_dim = '#9aa7b2',
  green = '#7ee787',
  green_dark = '#3fb950',
  blue = '#58a6ff',
  blue_dim = '#388bfd',
  purple = '#bc8cff',
  cyan = '#56d4dd',
  yellow = '#e3b341',
  orange = '#f0883e',
  red = '#ff7b72',
  gray = '#8b949e',
  contrast = '#0b0d10',
  white = '#ffffff',
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function apply()
  vim.g.colors_name = 'modern-dark-high-contrast'

  hl('Normal', { fg = palette.fg, bg = palette.bg })
  hl('NormalNC', { fg = palette.fg_dim, bg = palette.bg })
  hl('NormalFloat', { fg = palette.fg, bg = palette.bg_float })
  hl('FloatBorder', { fg = palette.blue, bg = palette.bg_float })
  hl('SignColumn', { fg = palette.fg_dim, bg = palette.bg })
  hl('LineNr', { fg = palette.green_dark, bg = palette.bg })
  hl('CursorLineNr', { fg = palette.fg_bright, bg = palette.bg_highlight, bold = true })
  hl('CursorLine', { bg = palette.bg_highlight })
  hl('ColorColumn', { bg = palette.bg_float })
  hl('Visual', { bg = palette.bg_selection })
  -- Saturated accents remain foregrounds; tinted surfaces carry highlighted text.
  hl('Search', { fg = palette.contrast, bg = palette.yellow, bold = true })
  hl('IncSearch', { fg = palette.contrast, bg = palette.orange, bold = true })
  hl('CurSearch', { fg = palette.contrast, bg = palette.orange, bold = true })
  hl('MatchParen', { fg = palette.contrast, bg = palette.purple, bold = true })
  hl('Pmenu', { fg = palette.fg, bg = palette.bg_float })
  hl('PmenuSel', { fg = palette.contrast, bg = palette.green, bold = true })
  hl('PmenuThumb', { bg = palette.green_dark })
  hl('WinSeparator', { fg = palette.blue_dim, bg = palette.bg })
  hl('StatusLine', { fg = palette.fg_bright, bg = palette.bg_float })
  hl('StatusLineNC', { fg = palette.fg_dim, bg = palette.bg_dark })
  hl('VertSplit', { fg = palette.blue_dim, bg = palette.bg })
  hl('StatusLineTerm', { fg = palette.fg_bright, bg = palette.bg_float })
  hl('StatusLineTermNC', { fg = palette.fg_dim, bg = palette.bg_dark })
  hl('WinBar', { fg = palette.fg_bright, bg = palette.bg, bold = true })
  hl('WinBarNC', { fg = palette.fg_dim, bg = palette.bg })
  hl('FoldColumn', { fg = palette.green_dark, bg = palette.bg })
  hl('CursorLineFold', { fg = palette.fg_bright, bg = palette.bg_highlight })
  hl('CursorLineSign', { fg = palette.fg_bright, bg = palette.bg_highlight })
  hl('Folded', { fg = palette.cyan, bg = palette.bg_float })
  hl('NonText', { fg = palette.green_dark, bg = palette.bg })
  hl('EndOfBuffer', { fg = palette.bg_dark, bg = palette.bg })
  hl('MsgSeparator', { fg = palette.blue_dim, bg = palette.bg })
  hl('MsgArea', { fg = palette.fg, bg = palette.bg })
  hl('ModeMsg', { fg = palette.fg_bright, bg = palette.bg, bold = true })
  hl('MoreMsg', { fg = palette.green, bg = palette.bg })
  hl('Question', { fg = palette.cyan, bg = palette.bg })
  hl('WildMenu', { fg = palette.contrast, bg = palette.green, bold = true })
  hl('MiniStatuslineModeNormal', { fg = palette.contrast, bg = palette.blue, bold = true })
  hl('MiniStatuslineModeInsert', { fg = palette.contrast, bg = palette.green, bold = true })
  hl('MiniStatuslineModeVisual', { fg = palette.contrast, bg = palette.purple, bold = true })
  hl('MiniStatuslineModeReplace', { fg = palette.contrast, bg = palette.red, bold = true })
  hl('MiniStatuslineModeCommand', { fg = palette.contrast, bg = palette.yellow, bold = true })
  hl('MiniStatuslineModeOther', { fg = palette.contrast, bg = palette.cyan, bold = true })
  hl('MiniStatuslineDevinfo', { fg = palette.cyan, bg = palette.bg_highlight })
  hl('MiniStatuslineFilename', { fg = palette.fg_bright, bg = palette.bg_float, bold = true })
  hl('MiniStatuslineFileinfo', { fg = palette.yellow, bg = palette.bg_highlight })
  hl('MiniStatuslineInactive', { fg = palette.fg_dim, bg = palette.bg_dark })
  hl('TabLine', { fg = palette.fg_dim, bg = palette.bg_float })
  hl('TabLineSel', { fg = palette.fg_bright, bg = palette.bg_dark, bold = true })

  hl('Comment', { fg = palette.gray })
  hl('Constant', { fg = palette.green })
  hl('String', { fg = palette.green })
  hl('Character', { fg = palette.green })
  hl('Number', { fg = palette.yellow })
  hl('Boolean', { fg = palette.yellow })
  hl('Identifier', { fg = palette.fg })
  hl('Function', { fg = palette.fg_bright, bold = true })
  hl('Statement', { fg = palette.blue })
  hl('Conditional', { fg = palette.blue, bold = true })
  hl('Repeat', { fg = palette.blue, bold = true })
  hl('Operator', { fg = palette.cyan })
  hl('Keyword', { fg = palette.blue, bold = true })
  hl('PreProc', { fg = palette.purple })
  hl('Type', { fg = palette.blue })
  hl('Special', { fg = palette.cyan })
  hl('Underlined', { fg = palette.cyan, underline = true })
  hl('Todo', { fg = palette.contrast, bg = palette.orange, bold = true })

  hl('@variable', { fg = palette.fg })
  hl('@variable.builtin', { fg = palette.cyan })
  hl('@constant', { fg = palette.green })
  hl('@constant.builtin', { fg = palette.yellow })
  hl('@string', { fg = palette.green })
  hl('@number', { fg = palette.yellow })
  hl('@function', { fg = palette.fg_bright, bold = true })
  hl('@function.builtin', { fg = palette.cyan })
  hl('@keyword', { fg = palette.blue, bold = true })
  hl('@keyword.return', { fg = palette.purple, bold = true })
  hl('@type', { fg = palette.blue })
  hl('@property', { fg = palette.green })
  hl('@punctuation', { fg = palette.fg_dim })
  hl('@tag', { fg = palette.blue })
  hl('@tag.attribute', { fg = palette.green })
  hl('@markup.heading', { fg = palette.fg_bright, bold = true })
  hl('@markup.link', { fg = palette.cyan, underline = true })
  hl('@markup.raw', { fg = palette.green })

  hl('DiagnosticError', { fg = palette.red })
  hl('DiagnosticWarn', { fg = palette.orange })
  hl('DiagnosticInfo', { fg = palette.cyan })
  hl('DiagnosticHint', { fg = palette.green })
  hl('DiagnosticUnderlineError', { undercurl = true, sp = palette.red })
  hl('DiagnosticUnderlineWarn', { undercurl = true, sp = palette.orange })
  hl('DiagnosticUnderlineInfo', { undercurl = true, sp = palette.cyan })
  hl('DiagnosticUnderlineHint', { undercurl = true, sp = palette.green })

  hl('DiffAdd', { fg = palette.green, bg = palette.bg_green })
  hl('DiffChange', { fg = palette.yellow, bg = palette.bg_yellow })
  hl('DiffDelete', { fg = palette.red, bg = palette.bg_red })
  hl('DiffText', { fg = palette.fg_bright, bg = palette.bg_orange, bold = true })
  hl('Added', { fg = palette.green })
  hl('Changed', { fg = palette.orange })
  hl('Removed', { fg = palette.red })
  hl('GitSignsAdd', { fg = palette.green })
  hl('GitSignsChange', { fg = palette.orange })
  hl('GitSignsDelete', { fg = palette.red })
  hl('GitSignsStagedAddLn', { fg = palette.fg, bg = palette.bg_green })
  hl('GitSignsStagedUntrackedLn', { fg = palette.fg, bg = palette.bg_green })
  hl('GitSignsStagedChangeLn', { fg = palette.fg, bg = palette.bg_yellow })
  hl('GitSignsStagedChangedeleteLn', { fg = palette.fg, bg = palette.bg_orange })

  hl('TelescopeBorder', { fg = palette.blue, bg = palette.bg_float })
  hl('TelescopeNormal', { fg = palette.fg, bg = palette.bg_float })
  hl('TelescopeSelection', { fg = palette.fg_bright, bg = palette.bg_highlight, bold = true })
  hl('TelescopeMatching', { fg = palette.yellow, bold = true })
  hl('WhichKey', { fg = palette.fg_bright, bold = true })
  hl('WhichKeyDesc', { fg = palette.green })
  hl('WhichKeyGroup', { fg = palette.blue })
  hl('BlinkCmpMenu', { fg = palette.fg, bg = palette.bg_float })
  hl('BlinkCmpMenuSelection', { fg = palette.contrast, bg = palette.green, bold = true })
  hl('BlinkCmpLabelMatch', { fg = palette.yellow, bold = true })
  hl('MarkdownH1', { fg = palette.blue, bold = true })
  hl('MarkdownH2', { fg = palette.green, bold = true })
  hl('MarkdownCode', { fg = palette.green, bg = palette.bg_float })

  -- render-markdown uses full-width heading backgrounds. Keep each level
  -- bright-on-tinted for readable structure without loud colour blocks.
  local heading_backgrounds = {
    palette.bg_blue,
    palette.bg_green,
    palette.bg_yellow,
    palette.bg_purple,
    palette.bg_orange,
    palette.bg_red,
  }
  local heading_foregrounds = {
    palette.blue,
    palette.green,
    palette.yellow,
    palette.purple,
    palette.orange,
    palette.red,
  }
  for level = 1, 6 do
    hl('RenderMarkdownH' .. level, { fg = heading_foregrounds[level], bold = true })
    hl('RenderMarkdownH' .. level .. 'Bg', {
      fg = palette.fg_bright,
      bg = heading_backgrounds[level],
      bold = true,
    })
  end

  -- Neogit's defaults assume a bundled colorscheme; keep its filled rows on
  -- the same neutral/tinted surfaces as the rest of the editor.
  hl('NeogitActiveItem', { fg = palette.fg_bright, bg = palette.bg_selection, bold = true })
  hl('NeogitDiffDelete', { fg = palette.red, bg = palette.bg_red })
  hl('NeogitDiffDeleteHighlight', { fg = palette.fg_bright, bg = palette.bg_red })
  hl('NeogitDiffHeaderHighlight', { fg = palette.fg_bright, bg = palette.bg_selection, bold = true })
  hl('NeogitHunkHeader', { fg = palette.fg_bright, bg = palette.bg_selection, bold = true })
  hl('NeogitHunkMergeHeader', { fg = palette.fg_bright, bg = palette.bg_purple, bold = true })

  -- Keep Neovim's terminal palette identical to Ghostty's theme.
  vim.g.terminal_color_0 = '#0b0d10'
  vim.g.terminal_color_1 = '#ff7b72'
  vim.g.terminal_color_2 = '#7ee787'
  vim.g.terminal_color_3 = '#e3b341'
  vim.g.terminal_color_4 = '#58a6ff'
  vim.g.terminal_color_5 = '#bc8cff'
  vim.g.terminal_color_6 = '#56d4dd'
  vim.g.terminal_color_7 = '#c9d1d9'
  vim.g.terminal_color_8 = '#6e7681'
  vim.g.terminal_color_9 = '#ffa198'
  vim.g.terminal_color_10 = '#9be9a8'
  vim.g.terminal_color_11 = '#f2cc60'
  vim.g.terminal_color_12 = '#79c0ff'
  vim.g.terminal_color_13 = '#d2a8ff'
  vim.g.terminal_color_14 = '#76e3ea'
  vim.g.terminal_color_15 = '#ffffff'
end

vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
  group = vim.api.nvim_create_augroup('modern_dark_theme', { clear = true }),
  callback = apply,
})

apply()
