local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add { gh 'folke/flash.nvim' }

require('flash').setup {
  search = {
    multi_window = true,
  },
}

vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash Treesitter jump' })

-- vim: ts=2 sts=2 sw=2 et
