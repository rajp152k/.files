local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add { gh 'Vigemus/iron.nvim' }

local iron = require 'iron.core'

iron.setup {
  config = {
    repl_definition = {
      python = {
        command = function(meta)
          local bufnr = meta.current_bufnr or meta.current_buffer
          local file = vim.api.nvim_buf_get_name(bufnr)
          local dir = file ~= '' and vim.fn.fnamemodify(file, ':p:h') or vim.fn.getcwd()

          return {
            'sh',
            '-c',
            'cd ' .. vim.fn.shellescape(dir) .. ' && exec uv run --with ipython ipython',
          }
        end,
        format = require('iron.fts.common').bracketed_paste_python,
        block_dividers = { '# %%', '#%%' },
      },
    },
    repl_open_cmd = 'botright 15split',
  },
  keymaps = {
    send_motion = '<leader>s',
    visual_send = '<leader>s',
    send_code_block = '<leader>b',
  },
}

vim.keymap.set('n', '<leader>R', '<cmd>IronRepl<CR>', { desc = 'Open Python [R]EPL' })

-- vim: ts=2 sts=2 sw=2 et
