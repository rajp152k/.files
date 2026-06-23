-- Hy development helpers: HyGround LSP and a builtin terminal REPL.

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'julienvincent/nvim-paredit', gh 'windwp/nvim-autopairs' }

local function register_hy_parser()
  local ok_parsers, parsers = pcall(require, 'nvim-treesitter.parsers')
  if not ok_parsers then return end

  parsers.hy = {
    install_info = {
      url = 'https://github.com/kwshi/tree-sitter-hy',
      files = { 'src/parser.c' },
      branch = 'main',
      generate_requires_npm = false,
      requires_generate_from_grammar = false,
    },
    filetype = 'hy',
  }
end

register_hy_parser()
vim.api.nvim_create_autocmd('User', {
  pattern = 'TSUpdate',
  callback = register_hy_parser,
})

local ok_paredit, paredit = pcall(require, 'nvim-paredit')
local ok_paredit_api, paredit_api = pcall(require, 'nvim-paredit.api')
if ok_paredit then paredit.setup {
  filetypes = { 'hy' },
  indent = { enabled = true },
} end

local ok_autopairs, autopairs = pcall(require, 'nvim-autopairs')
if ok_autopairs then autopairs.setup {
  enabled = function(bufnr) return vim.bo[bufnr].filetype == 'hy' end,
} end

local M = {}

local repl_job_id = nil
local repl_bufnr = nil

local root_markers = { 'workspace.cfg.hy', 'pyproject.toml', 'uv.lock', '.git' }
local hyground_project = '/Users/REDACTED/source/studying/exps/ThyForce/projects/hyground'

local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'Hy' }) end

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

local function path_exists(path) return path and vim.uv.fs_stat(path) ~= nil end

local function uv_project(root) return path_exists(vim.fs.joinpath(root, 'pyproject.toml')) or path_exists(vim.fs.joinpath(root, 'uv.lock')) end

local function repl_is_running() return repl_job_id and vim.fn.jobwait({ repl_job_id }, 0)[1] == -1 end

local function repl_command(root)
  local virtual_env = vim.env.VIRTUAL_ENV
  if virtual_env and virtual_env ~= '' then
    local venv_hy = vim.fs.joinpath(virtual_env, 'bin', 'hy')
    if vim.fn.executable(venv_hy) == 1 then return { venv_hy } end
  end

  local project_hy = vim.fs.joinpath(root, '.venv', 'bin', 'hy')
  if vim.fn.executable(project_hy) == 1 then return { project_hy } end

  if vim.fn.executable 'uv' == 1 and uv_project(root) then return { 'uv', 'run', '--with', 'hy', 'hy' } end

  local hy = vim.fn.exepath 'hy'
  if hy ~= '' then return { hy } end
end

local function ensure_repl()
  if repl_is_running() then return true end
  M.repl()
  return repl_is_running()
end

local function send_to_repl(text)
  if not text or text == '' then return end
  if not ensure_repl() then return end
  vim.fn.chansend(repl_job_id, text .. '\n')
end

local function absolute_cursor_index(lines)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_nr = cursor[1]
  local col = cursor[2]
  local index = 0

  for i = 1, line_nr - 1 do
    index = index + #lines[i] + 1
  end

  return index + col + 1
end

local function byte_to_position(text, index)
  local line = 1
  local line_start = 1

  for i = 1, math.max(index - 1, 0) do
    if text:byte(i) == 10 then
      line = line + 1
      line_start = i + 1
    end
  end

  return line, index - line_start
end

local function current_form_range()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines == 0 then return nil end

  local text = table.concat(lines, '\n')
  local cursor = math.min(absolute_cursor_index(lines), #text)
  local scan_end = cursor
  if text:byte(scan_end) == 41 then scan_end = scan_end - 1 end
  local open_stack = {}

  for i = 1, scan_end do
    local byte = text:byte(i)
    if byte == 40 then
      open_stack[#open_stack + 1] = i
    elseif byte == 41 and #open_stack > 0 then
      open_stack[#open_stack] = nil
    end
  end

  local start_index = open_stack[#open_stack]

  if not start_index then
    notify('No enclosing Hy form found.', vim.log.levels.WARN)
    return nil
  end

  local end_index = nil
  local depth = 0
  for i = start_index, #text do
    local byte = text:byte(i)
    if byte == 40 then
      depth = depth + 1
    elseif byte == 41 then
      depth = depth - 1
      if depth == 0 then
        end_index = i
        break
      end
    end
  end

  if not end_index then
    notify('No balanced Hy form found.', vim.log.levels.WARN)
    return nil
  end

  local start_line, start_col = byte_to_position(text, start_index)
  local end_line, end_col = byte_to_position(text, end_index)
  return start_line, start_col, end_line, end_col
end

function M.repl()
  if repl_is_running() and repl_bufnr and vim.api.nvim_buf_is_valid(repl_bufnr) then
    local win_id = vim.fn.bufwinid(repl_bufnr)
    if win_id ~= -1 then
      vim.api.nvim_set_current_win(win_id)
    else
      vim.cmd 'botright split'
      vim.api.nvim_set_current_buf(repl_bufnr)
      vim.cmd 'resize 12'
    end
    vim.cmd 'startinsert'
    return
  end

  local root = git_root() or project_root()
  local command = repl_command(root)

  if not command then
    notify('No Hy executable found. Use a uv project, activate a VIRTUAL_ENV with bin/hy, or install hy on PATH.', vim.log.levels.ERROR)
    return
  end

  vim.cmd 'botright split'
  vim.cmd 'enew'
  vim.cmd 'resize 12'
  local job_id = vim.fn.termopen(command, { cwd = root })
  if job_id <= 0 then
    repl_job_id = nil
    repl_bufnr = nil
    notify('Could not start Hy REPL.', vim.log.levels.ERROR)
    return
  end
  repl_job_id = job_id
  repl_bufnr = vim.api.nvim_get_current_buf()
  vim.cmd 'startinsert'
end

function M.restart_repl()
  if repl_is_running() then vim.fn.jobstop(repl_job_id) end
  repl_job_id = nil
  repl_bufnr = nil
  M.repl()
end

function M.send_line() send_to_repl(vim.api.nvim_get_current_line()) end

function M.send_range(opts)
  opts = opts or {}
  local start_line = opts.line1 or vim.fn.line "'<"
  local end_line = opts.line2 or vim.fn.line "'>"
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if #lines == 0 then return end
  send_to_repl(table.concat(lines, '\n'))
end

function M.send_form()
  local start_line, start_col, end_line, end_col = current_form_range()
  if not start_line then return end

  local lines = vim.api.nvim_buf_get_text(0, start_line - 1, start_col, end_line - 1, end_col + 1, {})
  if #lines == 0 then return end
  send_to_repl(table.concat(lines, '\n'))
end

function M.send_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines == 0 then return end
  send_to_repl(table.concat(lines, '\n'))
end

function M.interrupt()
  if not repl_is_running() then return end
  vim.fn.chansend(repl_job_id, '\003')
end

function M.reindex()
  if #vim.lsp.get_clients { bufnr = 0, name = 'hyground' } == 0 then
    notify('HyGround is not attached to this buffer.', vim.log.levels.WARN)
    return
  end

  local uri = vim.uri_from_bufnr(0)
  local params = {
    command = 'hyground.reindexWorkspace',
    arguments = { uri },
  }

  vim.lsp.buf_request(0, 'workspace/executeCommand', params, function(err)
    if err then
      notify('HyGround reindex failed: ' .. (err.message or tostring(err)), vim.log.levels.ERROR)
      return
    end
    notify 'HyGround reindex requested.'
  end)
end

vim.filetype.add {
  extension = {
    hy = 'hy',
  },
}

if vim.lsp and vim.lsp.config then
  vim.lsp.config('hyground', {
    -- Intentionally follows ThyForce's Polylith project entrypoint.
    cmd = { 'uvx', '--from', hyground_project, 'hyground' },
    filetypes = { 'hy' },
    root_markers = root_markers,
  })
  vim.lsp.enable 'hyground'
end

vim.api.nvim_create_user_command('HyRepl', M.repl, {
  desc = 'Open a Hy REPL in a terminal split',
})

vim.api.nvim_create_user_command('HyRestartRepl', M.restart_repl, {
  desc = 'Restart the Hy REPL terminal job',
})

vim.api.nvim_create_user_command('HySendLine', M.send_line, {
  desc = 'Send the current line to the Hy REPL',
})

vim.api.nvim_create_user_command('HySendSelection', M.send_range, {
  desc = 'Send the selected range to the Hy REPL',
  range = true,
})

vim.api.nvim_create_user_command('HySendForm', M.send_form, {
  desc = 'Send the current Hy form to the REPL',
})

vim.api.nvim_create_user_command('HySendBuffer', M.send_buffer, {
  desc = 'Send the current buffer to the Hy REPL',
})

vim.api.nvim_create_user_command('HyInterrupt', M.interrupt, {
  desc = 'Send Ctrl-C to the Hy REPL',
})

vim.api.nvim_create_user_command('HyReindex', M.reindex, {
  desc = 'Ask HyGround to reindex the current workspace',
})

local ok, which_key = pcall(require, 'which-key')
if ok then which_key.add { { '<leader>h', group = '[H]y' } } end

local function start_hy_treesitter(buf)
  if not vim.treesitter.language.add 'hy' then return end
  vim.treesitter.start(buf, 'hy')

  if vim.treesitter.query.get('hy', 'indents') ~= nil then vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local function ensure_hy_treesitter(buf)
  local ok_treesitter, treesitter = pcall(require, 'nvim-treesitter')
  if not ok_treesitter then return start_hy_treesitter(buf) end

  if vim.tbl_contains(treesitter.get_installed 'parsers', 'hy') then
    start_hy_treesitter(buf)
    return
  end

  local ok_install, install = pcall(treesitter.install, 'hy')
  if ok_install then install:await(function() start_hy_treesitter(buf) end) end
end

local function smart_angle(key)
  return function()
    if not ok_paredit_api then return key end

    local col = vim.api.nvim_win_get_cursor(0)[2]
    local char = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
    local action = nil

    if key == '>' then
      if char == ')' then
        action = paredit_api.slurp_forwards
      elseif char == '(' then
        action = paredit_api.barf_backwards
      end
    elseif key == '<' then
      if char == ')' then
        action = paredit_api.barf_forwards
      elseif char == '(' then
        action = paredit_api.slurp_backwards
      end
    end

    if action then
      vim.schedule(action)
      return '<Ignore>'
    end

    return key
  end
end

local function make_insert_pair_maps_nowait(buf)
  vim.schedule(function()
    for _, lhs in ipairs { '(', ')', '[', ']', '{', '}', '"', "'", '`', '<BS>' } do
      local map = vim.fn.maparg(lhs, 'i', false, true)
      if map and map.buffer == 1 and map.callback then
        vim.keymap.set('i', lhs, map.callback, {
          buffer = buf,
          desc = map.desc,
          expr = map.expr == 1,
          noremap = map.noremap == 1,
          nowait = true,
          replace_keycodes = map.replace_keycodes == 1,
        })
      end
    end
  end)
end

local function setup_hy_buffer(buf)
  ensure_hy_treesitter(buf)
  vim.keymap.set('n', '>', smart_angle '>', { buffer = buf, expr = true, nowait = true, desc = 'Paredit grow/move right' })
  vim.keymap.set('n', '<', smart_angle '<', { buffer = buf, expr = true, nowait = true, desc = 'Paredit shrink/move left' })
  make_insert_pair_maps_nowait(buf)
  local opts = { buffer = buf }
  vim.keymap.set('n', '<leader>hr', M.repl, vim.tbl_extend('force', opts, { desc = '[H]y [R]EPL' }))
  vim.keymap.set('n', '<leader>hR', M.restart_repl, vim.tbl_extend('force', opts, { desc = '[H]y restart [R]EPL' }))
  vim.keymap.set('n', '<leader>hl', M.send_line, vim.tbl_extend('force', opts, { desc = '[H]y send [L]ine' }))
  vim.keymap.set('x', '<leader>hx', ':HySendSelection<CR>', vim.tbl_extend('force', opts, { desc = '[H]y e[X]ecute selection' }))
  vim.keymap.set('n', '<leader>hf', M.send_form, vim.tbl_extend('force', opts, { desc = '[H]y send [F]orm' }))
  vim.keymap.set('n', '<leader>hb', M.send_buffer, vim.tbl_extend('force', opts, { desc = '[H]y send [B]uffer' }))
  vim.keymap.set('n', '<leader>hi', M.interrupt, vim.tbl_extend('force', opts, { desc = '[H]y [I]nterrupt' }))
  vim.keymap.set('n', '<leader>hI', M.reindex, vim.tbl_extend('force', opts, { desc = '[H]y re[I]ndex' }))
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'hy',
  callback = function(event) setup_hy_buffer(event.buf) end,
})

if vim.bo.filetype == 'hy' then setup_hy_buffer(0) end

return M
