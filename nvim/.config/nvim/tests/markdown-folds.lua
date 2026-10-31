-- Run from the Neovim config directory:
-- nvim --headless -u NONE -l tests/markdown-folds.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
local folds = require 'custom.markdown-folds'
local function check(lines, expected)
  assert(vim.deep_equal(folds.levels(lines, 4), expected), vim.inspect(folds.levels(lines, 4)))
end

check({ '# Heading', '- Parent', '  continuation', '  - Child', '    text', '- Sibling', 'prose', '## Next' },
  { '>1', '>2', 2, '>3', 3, '>2', 1, '>2' })
check({ '- Parent', '\t1. Child', '\t   text', '- Sibling' }, { '>1', '>2', 2, '>1' })
check({ '# Heading', '- Item', '  ````lua', '# not a heading', '~~~', '```', '  ````', '  text', '- Next' },
  { '>1', '>2', '>3', 3, 3, 3, 3, 2, '>2' })
check({ '# Heading', '---', '* * *', '###', '- Item' }, { '>1', 1, 1, '>3', '>4' })

-- Exercise actual Neovim fold boundaries and cache invalidation.
vim.api.nvim_buf_set_lines(0, 0, -1, false, {
  '# Heading', '- Parent', '  - Child', '    text', '- Sibling', '  text', '## Next', 'body',
})
_G.MarkdownHeadingFold = folds.foldexpr
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.MarkdownHeadingFold(v:lnum)'
vim.wo.foldlevel = 99
vim.cmd 'normal! zx'
for line, level in ipairs { 1, 2, 3, 3, 2, 2, 2, 2 } do
  assert(vim.fn.foldlevel(line) == level, 'fold level at line ' .. line)
end
vim.api.nvim_win_set_cursor(0, { 2, 0 })
vim.cmd 'normal! zc'
assert(vim.fn.foldclosed(2) == 2 and vim.fn.foldclosedend(2) == 4, 'parent item boundaries')
vim.cmd 'normal! zR'
vim.api.nvim_buf_set_lines(0, 2, 3, false, { '  plain continuation' })
vim.cmd 'normal! zx'
assert(vim.fn.foldlevel(3) == 2, 'recompute after edit')
print 'Markdown fold tests passed'
