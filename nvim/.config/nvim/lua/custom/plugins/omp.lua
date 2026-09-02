local function gh(repo) return 'https://github.com/' .. repo end

-- ACP chat UI. Agentic owns the Neovim surface; OMP is the ACP server.
vim.pack.add { gh 'carlos-algms/agentic.nvim' }

require('agentic').setup {
  provider = 'omp-acp',
  acp_providers = {
    ['omp-acp'] = {
      name = 'Oh My Pi',
      command = 'omp',
      args = { 'acp' },
    },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>aa', function()
  require('agentic').add_selection_or_file_to_context()
end, { desc = '[A]sk OMP about selection or file' })

vim.keymap.set({ 'n', 'v' }, '<leader>ao', function()
  require('agentic').toggle()
end, { desc = 'Toggle [O]MP chat' })

vim.keymap.set({ 'n', 'v' }, '<leader>an', function()
  require('agentic').new_session()
end, { desc = '[A] new OMP sessio[N]' })

-- vim: ts=2 sts=2 sw=2 et
