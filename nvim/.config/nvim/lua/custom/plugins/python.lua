-- Python virtual environments and an IPython REPL.
local gh = function(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'Vigemus/iron.nvim',
  gh 'linux-cultist/venv-selector.nvim',
}

require('venv-selector').setup {}

local iron = require 'iron.core'
local common = require 'iron.fts.common'

iron.setup {
  config = {
    scratch_repl = true,
    repl_definition = {
      python = {
        -- Use the active environment's interpreter, so the REPL sees its packages.
      command = function()
          local venv = vim.env.VIRTUAL_ENV
          local is_windows = vim.fn.has 'win32' == 1
          local python = is_windows and 'Scripts/python.exe' or 'bin/python'
          local ipython = is_windows and 'Scripts/ipython.exe' or 'bin/ipython'

          if venv then
            local venv_ipython = vim.fs.joinpath(venv, ipython)
            if vim.fn.executable(venv_ipython) == 1 then return { venv_ipython, '--no-autoindent' } end
            return { vim.fs.joinpath(venv, python), '-m', 'IPython', '--no-autoindent' }
          end

          local system_ipython = vim.fn.exepath 'ipython'
          if system_ipython ~= '' then return { system_ipython, '--no-autoindent' } end
          local system_python = vim.fn.exepath 'python3'
          if system_python == '' then system_python = 'python' end
          return { system_python, '-m', 'IPython', '--no-autoindent' }
        end,
        format = common.bracketed_paste_python,
        block_dividers = { '# %%', '#%%' },
        env = { PYTHON_BASIC_REPL = '1' },
      },
    },
    repl_open_cmd = 'bot 12 split',
  },
  keymaps = {
    toggle_repl = '<leader>pr',
    restart_repl = '<leader>pR',
    send_line = '<leader>ps',
    visual_send = '<leader>p',
    send_motion = '<leader>p',
  },
}

vim.keymap.set('n', '<leader>pv', '<Cmd>VenvSelect<CR>', { desc = '[P]ython [V]irtual environment' })

-- vim: ts=2 sts=2 sw=2 et
