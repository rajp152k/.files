-- Bit-Mage inspired high-contrast theme.
-- Reference: https://github.com/rajp152k/bit-mage-theme.el

local palette = {
  bg = '#050505',
  bg_dark = '#000000',
  bg_float = '#101010',
  bg_highlight = '#1a1a1a',
  bg_selection = '#2a0040',
  fg = '#22dd22',
  fg_bright = '#00ff00',
  fg_dim = '#1a9e1a',
  green = '#00ff7f',
  green_dark = '#2a8e2a',
  blue = '#7b68ee',
  blue_dim = '#5f4fcf',
  purple = '#8b008b',
  cyan = '#00ffff',
  yellow = '#ffd700',
  orange = '#ffaf00',
  red = '#ff5f5f',
  gray = '#808080',
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function apply()
  vim.g.colors_name = 'bit-mage'

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
  hl('Search', { fg = palette.bg_dark, bg = palette.yellow, bold = true })
  hl('IncSearch', { fg = palette.bg_dark, bg = palette.orange, bold = true })
  hl('CurSearch', { fg = palette.bg_dark, bg = palette.orange, bold = true })
  hl('MatchParen', { fg = palette.fg_bright, bg = palette.purple, bold = true })
  hl('Pmenu', { fg = palette.fg, bg = palette.bg_float })
  hl('PmenuSel', { fg = palette.bg_dark, bg = palette.green, bold = true })
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
  hl('WildMenu', { fg = palette.bg_dark, bg = palette.green, bold = true })
  hl('MiniStatuslineModeNormal', { fg = palette.bg_dark, bg = palette.fg_bright, bold = true })
  hl('MiniStatuslineModeInsert', { fg = palette.bg_dark, bg = palette.green, bold = true })
  hl('MiniStatuslineModeVisual', { fg = palette.bg_dark, bg = palette.purple, bold = true })
  hl('MiniStatuslineModeReplace', { fg = palette.bg_dark, bg = palette.red, bold = true })
  hl('MiniStatuslineModeCommand', { fg = palette.bg_dark, bg = palette.yellow, bold = true })
  hl('MiniStatuslineModeOther', { fg = palette.bg_dark, bg = palette.cyan, bold = true })
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
  hl('Todo', { fg = palette.bg_dark, bg = palette.orange, bold = true })

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

  hl('DiffAdd', { fg = palette.green, bg = '#002a00' })
  hl('DiffChange', { fg = palette.yellow, bg = '#2a2200' })
  hl('DiffDelete', { fg = palette.red, bg = '#2a0000' })
  hl('DiffText', { fg = palette.bg_dark, bg = palette.orange, bold = true })
  hl('Added', { fg = palette.green })
  hl('Changed', { fg = palette.orange })
  hl('Removed', { fg = palette.red })
  hl('GitSignsAdd', { fg = palette.green })
  hl('GitSignsChange', { fg = palette.orange })
  hl('GitSignsDelete', { fg = palette.red })

  hl('TelescopeBorder', { fg = palette.blue, bg = palette.bg_float })
  hl('TelescopeNormal', { fg = palette.fg, bg = palette.bg_float })
  hl('TelescopeSelection', { fg = palette.fg_bright, bg = palette.bg_highlight, bold = true })
  hl('TelescopeMatching', { fg = palette.yellow, bold = true })
  hl('WhichKey', { fg = palette.fg_bright, bold = true })
  hl('WhichKeyDesc', { fg = palette.green })
  hl('WhichKeyGroup', { fg = palette.blue })
  hl('BlinkCmpMenu', { fg = palette.fg, bg = palette.bg_float })
  hl('BlinkCmpMenuSelection', { fg = palette.bg_dark, bg = palette.green, bold = true })
  hl('BlinkCmpLabelMatch', { fg = palette.yellow, bold = true })
  hl('MarkdownH1', { fg = palette.fg_bright, bold = true })
  hl('MarkdownH2', { fg = palette.green, bold = true })
  hl('MarkdownCode', { fg = palette.green, bg = palette.bg_float })

  vim.g.terminal_color_0 = palette.bg_dark
  vim.g.terminal_color_1 = palette.red
  vim.g.terminal_color_2 = palette.green
  vim.g.terminal_color_3 = palette.orange
  vim.g.terminal_color_4 = palette.blue
  vim.g.terminal_color_5 = palette.purple
  vim.g.terminal_color_6 = palette.cyan
  vim.g.terminal_color_7 = palette.fg
  vim.g.terminal_color_8 = palette.gray
  vim.g.terminal_color_9 = palette.red
  vim.g.terminal_color_10 = palette.fg_bright
  vim.g.terminal_color_11 = palette.yellow
  vim.g.terminal_color_12 = palette.blue
  vim.g.terminal_color_13 = palette.purple
  vim.g.terminal_color_14 = palette.cyan
  vim.g.terminal_color_15 = '#ffffff'
end

vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
  group = vim.api.nvim_create_augroup('bit_mage_theme', { clear = true }),
  callback = apply,
})

apply()
