local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'MeanderingProgrammer/render-markdown.nvim',
  gh 'tadmccorkle/markdown.nvim',
}

require('render-markdown').setup {
  completions = { lsp = { enabled = true } },
  sign = { enabled = false },
  heading = {
    sign = false,
    icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
    position = 'inline',
  },
  code = {
    sign = false,
    language_icon = false,
  },
  checkbox = {
    unchecked = { icon = '[ ] ' },
    checked = { icon = '[x] ' },
    custom = {
      todo = { raw = '[-]', rendered = '[-] ' },
    },
  },
}

require('markdown').setup {
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map('n', '<leader>mt', '<Cmd>RenderMarkdown buf_toggle<CR>', '[M]arkdown render [T]oggle')
    map('n', '<leader>mp', '<Cmd>RenderMarkdown preview<CR>', '[M]arkdown render [P]review')
    map('n', '<leader>mx', '<Cmd>MDTaskToggle<CR>', '[M]arkdown task toggle')
    map('x', '<leader>mx', ':MDTaskToggle<CR>', '[M]arkdown task toggle')
    map({ 'n', 'i' }, '<leader>mo', '<Cmd>MDListItemBelow<CR>', '[M]arkdown list item bel[O]w')
    map({ 'n', 'i' }, '<leader>mO', '<Cmd>MDListItemAbove<CR>', '[M]arkdown list item ab[O]ve')
  end,
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.colorcolumn = ''
  end,
})

local ok, which_key = pcall(require, 'which-key')
if ok then which_key.add { { '<leader>m', group = '[M]arkdown' } } end

-- vim: ts=2 sts=2 sw=2 et
