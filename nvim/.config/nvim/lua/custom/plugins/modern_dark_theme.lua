-- High-contrast green on black.

local palette = {
  bg = '#000000',
  bg_dark = '#000000',
  bg_float = '#000000',
  bg_highlight = '#002b00',
  bg_selection = '#00b300',
  bg_yellow = '#003b00',
  bg_orange = '#004d00',
  bg_green = '#003b00',
  bg_blue = '#002b00',
  bg_purple = '#004000',
  bg_red = '#005200',
  fg = '#00ff00',
  fg_bright = '#ffffff',
  fg_dim = '#39ff14',
  green = '#00ff00',
  green_dark = '#006600',
  blue = '#39ff14',
  blue_dim = '#00b300',
  purple = '#7fff00',
  cyan = '#b6ff00',
  yellow = '#b6ff00',
  orange = '#7fff00',
  red = '#39ff14',
  gray = '#00b300',
  contrast = '#000000',
  white = '#ffffff',
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function apply()
  vim.g.colors_name = 'green-black-high-contrast'

  hl('Normal', { fg = palette.fg, bg = palette.bg })
  hl('NormalNC', { fg = palette.fg_dim, bg = palette.bg })
  hl('NormalFloat', { fg = palette.fg, bg = palette.bg_float })
  hl('FloatBorder', { fg = palette.green, bg = palette.bg_float })
  hl('BlinkCmpDocBorder', { fg = palette.green, bg = palette.bg_float })
  hl('BlinkCmpSignatureHelpBorder', { fg = palette.green, bg = palette.bg_float })
  hl('SignColumn', { fg = palette.fg_dim, bg = palette.bg })
  hl('LineNr', { fg = palette.green_dark, bg = palette.bg })
  hl('CursorLineNr', { fg = palette.fg_bright, bg = palette.bg_highlight, bold = true })
  hl('CursorLine', { bg = palette.bg_highlight })
  hl('ColorColumn', { bg = palette.bg_float })
  hl('Visual', { bg = palette.bg_selection })
  -- Bright text is reserved for active targets; surfaces remain black or deep green.
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

  -- render-markdown uses full-width heading backgrounds.
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

  -- Keep Neogit's filled rows consistent with the rest of the editor.
  hl('NeogitActiveItem', { fg = palette.fg_bright, bg = palette.bg_selection, bold = true })
  hl('NeogitDiffDelete', { fg = palette.red, bg = palette.bg_red })
  hl('NeogitDiffDeleteHighlight', { fg = palette.fg_bright, bg = palette.bg_red })
  hl('NeogitDiffHeaderHighlight', { fg = palette.fg_bright, bg = palette.bg_selection, bold = true })
  hl('NeogitHunkHeader', { fg = palette.fg_bright, bg = palette.bg_selection, bold = true })
  hl('NeogitHunkMergeHeader', { fg = palette.fg_bright, bg = palette.bg_purple, bold = true })

  -- Match Ghostty's terminal palette.
  vim.g.terminal_color_0 = '#000000'
  vim.g.terminal_color_1 = '#00ff00'
  vim.g.terminal_color_2 = '#00ff00'
  vim.g.terminal_color_3 = '#7fff00'
  vim.g.terminal_color_4 = '#00ff00'
  vim.g.terminal_color_5 = '#39ff14'
  vim.g.terminal_color_6 = '#00ff00'
  vim.g.terminal_color_7 = '#ccffcc'
  vim.g.terminal_color_8 = '#006600'
  vim.g.terminal_color_9 = '#39ff14'
  vim.g.terminal_color_10 = '#39ff14'
  vim.g.terminal_color_11 = '#b6ff00'
  vim.g.terminal_color_12 = '#39ff14'
  vim.g.terminal_color_13 = '#7fff00'
  vim.g.terminal_color_14 = '#b6ff00'
  vim.g.terminal_color_15 = '#ffffff'
end

vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
  group = vim.api.nvim_create_augroup('green_black_theme', { clear = true }),
  callback = apply,
})

apply()
