local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add {
  { src = gh 'NeogitOrg/neogit', version = vim.version.range '*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
  gh 'sindrets/diffview.nvim',
}

require('neogit').setup {
  integrations = {
    diffview = true,
  },
}

local function map(lhs, rhs, desc)
  if vim.fn.maparg(lhs, 'n') == '' then
    vim.keymap.set('n', lhs, rhs, { desc = desc })
  end
end

map('<leader>gg', '<Cmd>Neogit<CR>', '[G]it status')
map('<leader>gc', '<Cmd>Neogit commit<CR>', '[G]it [C]ommit')
map('<leader>gd', '<Cmd>Neogit diff<CR>', '[G]it [D]iff')
map('<leader>gl', '<Cmd>Neogit log<CR>', '[G]it [L]og')
map('<leader>gs', '<Cmd>Neogit stash<CR>', '[G]it [S]tash')

local ok, which_key = pcall(require, 'which-key')
if ok then
  which_key.add { { '<leader>g', group = '[G]it' } }
end

-- vim: ts=2 sts=2 sw=2 et
