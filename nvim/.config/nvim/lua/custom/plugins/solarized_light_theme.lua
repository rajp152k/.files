-- Solarized Light with stronger contrast, matching Ghostty and tmux.

local palette = {
  bg = '#fdf6e3',
  bg_dark = '#eee8d5',
  bg_float = '#eee8d5',
  bg_highlight = '#ded7c3',
  bg_selection = '#c8d7d4',
  bg_yellow = '#eee5be',
  bg_orange = '#f1dfb8',
  bg_green = '#e4edcf',
  bg_blue = '#d5e8ed',
  bg_purple = '#eaddea',
  bg_red = '#f3d8cf',
  fg = '#40565c',
  fg_bright = '#263f45',
  fg_dim = '#657b83',
  green = '#607400',
  green_dark = '#526a38',
  blue = '#006a96',
  blue_dim = '#087da8',
  purple = '#963e82',
  cyan = '#16716d',
  yellow = '#826200',
  orange = '#947200',
  red = '#c23b22',
  gray = '#586e75',
  contrast = '#263f45',
  white = '#fdf6e3',
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

local function apply()
  vim.g.colors_name = 'solarized-light-high-contrast'

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
  -- On a light theme, dark accents are foregrounds; backgrounds use pale tints.
  hl('Search', { fg = palette.contrast, bg = palette.bg_yellow, bold = true })
  hl('IncSearch', { fg = palette.contrast, bg = palette.bg_orange, bold = true })
  hl('CurSearch', { fg = palette.contrast, bg = palette.bg_orange, bold = true })
  hl('MatchParen', { fg = palette.white, bg = palette.purple, bold = true })
  hl('Pmenu', { fg = palette.fg, bg = palette.bg_float })
  hl('PmenuSel', { fg = palette.white, bg = palette.green, bold = true })
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
  hl('WildMenu', { fg = palette.white, bg = palette.green, bold = true })
  hl('MiniStatuslineModeNormal', { fg = palette.white, bg = palette.blue, bold = true })
  hl('MiniStatuslineModeInsert', { fg = palette.white, bg = palette.green, bold = true })
  hl('MiniStatuslineModeVisual', { fg = palette.white, bg = palette.purple, bold = true })
  hl('MiniStatuslineModeReplace', { fg = palette.white, bg = palette.red, bold = true })
  hl('MiniStatuslineModeCommand', { fg = palette.white, bg = palette.yellow, bold = true })
  hl('MiniStatuslineModeOther', { fg = palette.white, bg = palette.cyan, bold = true })
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
  hl('Todo', { fg = palette.contrast, bg = palette.bg_orange, bold = true })

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
  hl('DiffText', { fg = palette.contrast, bg = palette.bg_orange, bold = true })
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
  hl('BlinkCmpMenuSelection', { fg = palette.white, bg = palette.green, bold = true })
  hl('BlinkCmpLabelMatch', { fg = palette.yellow, bold = true })
  hl('MarkdownH1', { fg = palette.blue, bold = true })
  hl('MarkdownH2', { fg = palette.green, bold = true })
  hl('MarkdownCode', { fg = palette.green, bg = palette.bg_float })

  -- render-markdown uses full-width heading backgrounds. Keep every pairing
  -- dark-on-pale rather than inheriting its dark-theme defaults.
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
      fg = palette.contrast,
      bg = heading_backgrounds[level],
      bold = true,
    })
  end

  -- Keep Neovim's terminal palette identical to Ghostty's theme.
  vim.g.terminal_color_0 = palette.contrast
  vim.g.terminal_color_1 = palette.red
  vim.g.terminal_color_2 = palette.green
  vim.g.terminal_color_3 = palette.yellow
  vim.g.terminal_color_4 = palette.blue
  vim.g.terminal_color_5 = palette.purple
  vim.g.terminal_color_6 = palette.cyan
  vim.g.terminal_color_7 = palette.bg_dark
  vim.g.terminal_color_8 = palette.gray
  vim.g.terminal_color_9 = '#d34b31'
  vim.g.terminal_color_10 = '#718500'
  vim.g.terminal_color_11 = '#947200'
  vim.g.terminal_color_12 = palette.blue_dim
  vim.g.terminal_color_13 = '#a84d94'
  vim.g.terminal_color_14 = '#238580'
  vim.g.terminal_color_15 = palette.white
end

vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
  group = vim.api.nvim_create_augroup('solarized_light_theme', { clear = true }),
  callback = apply,
})

apply()
