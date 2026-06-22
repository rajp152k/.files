-- Minimal Python workflow helpers: uv-managed .venv and a builtin terminal REPL.

local M = {}
local repl_job_id = nil

local root_markers = { 'pyproject.toml', 'uv.lock', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' }

local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'Python uv' }) end

local function buffer_dir()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then return nil end
  return vim.fs.dirname(name)
end

local function project_root()
  local buf_dir = buffer_dir()
  local path = buf_dir or vim.uv.cwd()
  return vim.fs.root(path, root_markers) or buf_dir or vim.uv.cwd()
end

local function git_root()
  local buf_dir = buffer_dir()
  local path = buf_dir or vim.uv.cwd()
  return vim.fs.root(path, { '.git' })
end

local function uv_available()
  if vim.fn.executable 'uv' == 1 then return true end

  notify('uv is not available on PATH; install uv to manage Python virtualenvs.', vim.log.levels.ERROR)
  return false
end

local function path_list(value)
  if not value or value == '' then return {} end
  return vim.split(value, package.config:sub(1, 1) == '\\' and ';' or ':', { plain = true, trimempty = true })
end

local function prepend_path_once(bin_dir, old_bin_dir)
  local parts = path_list(vim.env.PATH)
  local next_parts = { bin_dir }

  for _, part in ipairs(parts) do
    if part ~= bin_dir and part ~= old_bin_dir and part ~= '' then next_parts[#next_parts + 1] = part end
  end

  vim.env.PATH = table.concat(next_parts, package.config:sub(1, 1) == '\\' and ';' or ':')
end

local function venv_paths(venv_dir)
  local bin_dir = vim.fs.joinpath(venv_dir, 'bin')
  return bin_dir, vim.fs.joinpath(bin_dir, 'python')
end

local function update_python_lsp(python)
  if vim.lsp.config.pyright then
    vim.lsp.config(
      'pyright',
      vim.tbl_deep_extend('force', vim.lsp.config.pyright, {
        settings = { python = { pythonPath = python } },
      })
    )
  end

  for _, client in ipairs(vim.lsp.get_clients { name = 'pyright' }) do
    client.config.settings = vim.tbl_deep_extend('force', client.config.settings or {}, {
      python = { pythonPath = python },
    })
    client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
  end
end

local function apply_venv(venv_dir)
  local old_venv = vim.env.VIRTUAL_ENV
  local old_bin_dir = old_venv and vim.fs.joinpath(old_venv, 'bin') or nil
  local bin_dir, python = venv_paths(venv_dir)

  if vim.fn.executable(python) ~= 1 then
    notify('No Python executable found in ' .. venv_dir, vim.log.levels.ERROR)
    return false
  end

  vim.env.VIRTUAL_ENV = venv_dir
  prepend_path_once(bin_dir, old_bin_dir)
  vim.g.python3_host_prog = python
  update_python_lsp(python)
  notify('Using Python virtualenv: ' .. venv_dir)
  return true
end

local function default_venv_dir() return vim.fs.joinpath(git_root() or project_root(), '.venv') end

local function normalize_dir(path) return vim.fs.normalize(vim.fn.fnamemodify(path, ':p')) end

local function existing_venv_candidates()
  local seen = {}
  local candidates = {}

  local function add(path)
    if not path or seen[path] then return end

    local _, python = venv_paths(path)
    if vim.fn.executable(python) == 1 then
      seen[path] = true
      candidates[#candidates + 1] = path
    end
  end

  add(default_venv_dir())
  add(vim.fs.joinpath(vim.uv.cwd(), '.venv'))

  if vim.env.VIRTUAL_ENV then add(vim.env.VIRTUAL_ENV) end

  return candidates
end

function M.create_venv(opts)
  if not uv_available() then return end

  opts = opts or {}
  local arg = opts.args
  local venv_dir = arg and arg ~= '' and normalize_dir(arg) or default_venv_dir()
  local parent = vim.fs.dirname(venv_dir)

  notify('Creating virtualenv: ' .. venv_dir)
  vim.system({ 'uv', 'venv', venv_dir }, { cwd = parent, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local message = vim.trim(result.stderr or result.stdout or '')
        notify(message ~= '' and message or ('uv venv failed with exit code ' .. result.code), vim.log.levels.ERROR)
        return
      end

      apply_venv(venv_dir)
    end)
  end)
end

function M.select_venv(opts)
  opts = opts or {}
  local arg = opts.args
  if arg and arg ~= '' then
    apply_venv(normalize_dir(arg))
    return
  end

  local candidates = existing_venv_candidates()
  if #candidates == 0 then
    notify('No .venv found for this project. Run :UvVenv to create one.', vim.log.levels.WARN)
    return
  end

  vim.ui.select(candidates, { prompt = 'Select Python virtualenv' }, function(choice)
    if choice then apply_venv(choice) end
  end)
end

local function repl_is_running() return repl_job_id and vim.fn.jobwait({ repl_job_id }, 0)[1] == -1 end

local function send_to_repl(text, opts)
  if not repl_is_running() then M.python_repl() end
  if not repl_is_running() then return end

  opts = opts or {}
  local payload = text
  if opts.exec then payload = 'exec(' .. vim.json.encode(text) .. ')' end
  vim.fn.chansend(repl_job_id, payload .. '\n')
end

local function repl_command(python)
  local python_dir = vim.fs.dirname(python)
  local venv_ipython = vim.fs.joinpath(python_dir, 'ipython')
  if vim.fn.executable(venv_ipython) == 1 then return { venv_ipython, '--no-autoindent' } end

  local ipython = vim.fn.exepath 'ipython'
  if ipython ~= '' then return { ipython, '--no-autoindent' } end

  return { python }
end

function M.python_repl()
  local venv_dir = vim.env.VIRTUAL_ENV
  if not venv_dir or venv_dir == '' then
    local candidate = default_venv_dir()
    local _, python = venv_paths(candidate)
    if vim.fn.executable(python) == 1 then
      apply_venv(candidate)
      venv_dir = candidate
    end
  end

  local python = vim.g.python3_host_prog
  if type(python) ~= 'string' or vim.fn.executable(python) ~= 1 then python = vim.fn.exepath 'python3' end

  if python == '' then
    notify('No Python executable found. Create/select a venv first or install python3.', vim.log.levels.ERROR)
    return
  end

  vim.cmd 'botright split'
  vim.cmd 'enew'
  vim.cmd 'resize 12'
  vim.fn.termopen(repl_command(python), { cwd = project_root() })
  repl_job_id = vim.b.terminal_job_id
  vim.cmd 'startinsert'
end

function M.send_line() send_to_repl(vim.api.nvim_get_current_line()) end

function M.send_range(opts)
  opts = opts or {}
  local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
  if #lines == 0 then return end
  send_to_repl(table.concat(lines, '\n'), { exec = #lines > 1 })
end

vim.api.nvim_create_user_command('UvVenv', M.create_venv, {
  nargs = '?',
  complete = 'dir',
  desc = 'Create a uv virtualenv and select it',
})

vim.api.nvim_create_user_command('UvSelectVenv', M.select_venv, {
  nargs = '?',
  complete = 'dir',
  desc = 'Select a Python virtualenv for Neovim',
})

vim.api.nvim_create_user_command('PythonRepl', M.python_repl, {
  desc = 'Open a Python REPL in a terminal split',
})

vim.api.nvim_create_user_command('PythonSendLine', M.send_line, {
  desc = 'Send the current line to the Python REPL',
})

vim.api.nvim_create_user_command('PythonSendSelection', M.send_range, {
  range = true,
  desc = 'Send the selected lines to the Python REPL',
})

local ok, which_key = pcall(require, 'which-key')
if ok then which_key.add { { '<leader>p', group = '[P]ython' } } end

vim.keymap.set('n', '<leader>pv', M.create_venv, { desc = '[P]ython [V]env create/select' })
vim.keymap.set('n', '<leader>ps', M.select_venv, { desc = '[P]ython [S]elect venv' })
vim.keymap.set('n', '<leader>pr', M.python_repl, { desc = '[P]ython [R]EPL' })
vim.keymap.set('n', '<leader>pl', M.send_line, { desc = '[P]ython send [L]ine' })
vim.keymap.set('x', '<leader>px', ':PythonSendSelection<CR>', { desc = '[P]ython e[X]ecute selection' })

return M
