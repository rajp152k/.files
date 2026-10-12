-- Common Lisp: Vlime and native LSP share one persistent, project-local SBCL.
vim.pack.add {
  { src = 'https://github.com/vlime/vlime', version = 'e276e9a6f37d2699a3caa63be19314f5a19a1481' },
  { src = 'https://github.com/ramfjord/swank-lsp', version = '20b04439b2ecd82c33d1b65f3a43c3a27b906c62' },
  'https://github.com/julienvincent/nvim-paredit',
}

local vlime = vim.fn.stdpath 'data' .. '/site/pack/core/opt/vlime/vim'
vim.opt.runtimepath:append(vlime)
vim.g.vlime_leader = '<Space>lv'
vim.g.vlime_enable_autodoc = false
-- Keep Vlime's debugger/inspector keys, but configure source buffers ourselves.
vim.cmd 'runtime autoload/vlime/ui/mapping.vim'
local mappings = vim.g.vlime_default_mappings
mappings.lisp = {}
vim.g.vlime_default_mappings = mappings
-- Keep Vimscript dictionaries containing Funcrefs on the Vimscript side.
vim.cmd [[
  let g:lisp_dev_connections = {}
  function! LispDevConnect(root, port) abort
    let conn = get(g:lisp_dev_connections, a:root, v:null)
    if type(conn) == type(v:null) || !conn.IsConnected()
      if type(conn) != type(v:null) | call vlime#connection#Close(conn) | endif
      let conn = vlime#plugin#ConnectREPL('127.0.0.1', a:port, '', 3000, a:root)
      if type(conn) == type(v:null) | return 0 | endif
      let g:lisp_dev_connections[a:root] = conn
    endif
    let b:vlime_conn = conn
    return 1
  endfunction
  function! LispDevDisconnect(root) abort
    if has_key(g:lisp_dev_connections, a:root)
      let conn = remove(g:lisp_dev_connections, a:root)
      call vlime#connection#Close(conn)
    endif
  endfunction
]]

local M = {}
local launcher = vim.fn.stdpath 'config' .. '/scripts/lisp-dev'

function M.root(buf)
  local path = vim.api.nvim_buf_get_name(buf or 0)
  if path == '' then return vim.uv.fs_realpath(vim.fn.getcwd()) end
  return vim.uv.fs_realpath(vim.fs.root(path, { '.git', 'qlfile', '.lisp-dev-root' }) or vim.fs.dirname(path))
end

function M.state(root)
  return (vim.env.XDG_CACHE_HOME or vim.env.HOME .. '/.cache') .. '/nvim/common-lisp/' .. vim.fn.sha256(root)
end

local function port(root, name)
  local path = M.state(root) .. '/' .. name .. '.port'
  if vim.fn.filereadable(path) ~= 1 then return end
  local value = tonumber(vim.fn.readfile(path)[1])
  if value and value > 0 and value < 65536 then return value end
end

function M.attach(buf, root)
  local value = port(root, 'lsp')
  if not value then return end
  return vim.lsp.start({
    name = 'swank_lsp',
    root_dir = root,
    cmd = vim.lsp.rpc.connect('127.0.0.1', value),
    capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), {
      general = { positionEncodings = { 'utf-8', 'utf-16' } },
    }),
  }, { bufnr = buf })
end

function M.connect(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local root = M.root(buf)
  local value = port(root, 'vlime')
  if not value then
    vim.notify('Start this project image with :LispStart [system]', vim.log.levels.WARN)
    return
  end
  vim.api.nvim_buf_call(buf, function()
    if vim.fn.LispDevConnect(root, value) == 1 then M.attach(buf, root) end
  end)
end

local function run(action, system)
  local buf = vim.api.nvim_get_current_buf()
  local root = M.root(buf)
  local argv = { launcher, action, root }
  if system and system ~= '' then table.insert(argv, system) end
  vim.system(argv, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(result.stderr ~= '' and result.stderr or result.stdout, vim.log.levels.ERROR)
        return
      end
      vim.notify(vim.trim(result.stdout))
      if action == 'start' and vim.api.nvim_buf_is_valid(buf) then M.connect(buf) end
      if action == 'stop' then
        vim.fn.LispDevDisconnect(root)
        for _, client in ipairs(vim.lsp.get_clients { name = 'swank_lsp' }) do
          if client.root_dir == root then client:stop() end
        end
      end
    end)
  end)
end

vim.api.nvim_create_user_command('LispStart', function(opts) run('start', opts.args) end, { nargs = '?' })
vim.api.nvim_create_user_command('LispConnect', function() M.connect() end, {})
vim.api.nvim_create_user_command('LispStop', function() run('stop') end, {})
vim.api.nvim_create_user_command('LispStatus', function() run('status') end, {})
vim.api.nvim_create_user_command('LispHelp', function()
  vim.cmd.edit(vim.fn.fnameescape(vim.fn.stdpath 'config' .. '/doc/common-lisp.md'))
end, {})
vim.api.nvim_create_user_command('LispConsole', function()
  local root = M.root()
  local session = 'lisp-' .. vim.fn.sha256(root):sub(1, 16)
  vim.cmd 'botright 15new'
  vim.fn.jobstart({ 'env', '-u', 'TMUX', 'tmux', 'attach-session', '-t', session }, { term = true })
  vim.cmd.startinsert()
end, {})

local paredit = require 'nvim-paredit'
local mini_pairs = require 'mini.pairs'

-- Keep pair insertion limited to Lisp buffers. MiniPairs also gives these
-- buffers paired backspace, close-paren skipping, and newline expansion.
mini_pairs.setup {
  mappings = {
    ['('] = false,
    [')'] = false,
    ['['] = false,
    [']'] = false,
    ['{'] = false,
    ['}'] = false,
    ['"'] = false,
    ["'"] = false,
    ['`'] = false,
  },
}

local ts_context = require 'nvim-paredit.treesitter.context'
local ts_forms = require 'nvim-paredit.treesitter.forms'

local function cursor_on_form_edge(edge_name)
  local context = ts_context.create_context()
  if not context then return false end

  local form = ts_forms.find_nearest_form(context.node, context)
  if not form then return false end

  local edge = ts_forms.get_form_edges(form, context)[edge_name]
  local row, col
  if edge_name == 'left' then
    if edge.text:sub(-1) ~= '(' then return false end
    row, col = edge.range[3], edge.range[4] - 1
  else
    if edge.text ~= ')' then return false end
    row, col = edge.range[1], edge.range[2]
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  return cursor[1] - 1 == row and cursor[2] == col
end

local function smart_backward()
  if cursor_on_form_edge 'left' then
    paredit.api.slurp_backwards()
  else
    paredit.api.barf_backwards()
  end
end

local function smart_forward()
  if cursor_on_form_edge 'right' then
    paredit.api.slurp_forwards()
  else
    paredit.api.barf_forwards()
  end
end

paredit.setup {
  filetypes = { 'lisp' },
  use_default_keys = false,
  indent = { enabled = true },
  keys = {
    ['<'] = { smart_backward, 'Slurp or barf backward' },
    ['>'] = { smart_forward, 'Slurp or barf forward' },
    ['<Space>lp'] = { paredit.api.raise_form, 'Raise form' },
    ['af'] = { paredit.api.select_around_form, 'Around form', mode = { 'o', 'v' }, repeatable = false },
    ['if'] = { paredit.api.select_in_form, 'Inside form', mode = { 'o', 'v' }, repeatable = false },
    ['aF'] = { paredit.api.select_around_top_level_form, 'Around top-level form', mode = { 'o', 'v' }, repeatable = false },
    ['iF'] = { paredit.api.select_in_top_level_form, 'Inside top-level form', mode = { 'o', 'v' }, repeatable = false },
  },
}

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('CommonLispDevelopment', { clear = true }),
  pattern = 'lisp',
  callback = function(event)
    mini_pairs.map_buf(event.buf, 'i', '(', { action = 'open', pair = '()' })
    mini_pairs.map_buf(event.buf, 'i', ')', { action = 'close', pair = '()' })
    mini_pairs.map_buf(event.buf, 'i', '"', {
      action = 'closeopen',
      pair = '""',
      neigh_pattern = '^[^\\]',
      register = { cr = false },
    })
    vim.opt_local.matchpairs = '(:)'
    vim.opt_local.showmatch = true
    vim.bo[event.buf].omnifunc = 'vlime#plugin#CompleteFunc'
    -- Lisp-aware macro indentation, without formatting on save.
    vim.bo[event.buf].indentexpr = 'vlime#plugin#CalcCurIndent()'
    local function map(key, rhs, desc, mode)
      vim.keymap.set(mode or 'n', key, rhs, { buffer = event.buf, desc = 'Lisp: ' .. desc })
    end
    local function call(name, expr)
      return '<Cmd>call vlime#plugin#' .. name .. '(' .. (expr or '') .. ')<CR>'
    end
    map('<Space>l?', '<Cmd>LispHelp<CR>', 'setup and key reference')
    map('<Space>ls', '<Cmd>LispStart<CR>', 'start image')
    map('<Space>lc', '<Cmd>LispConnect<CR>', 'connect')
    map('<Space>lq', '<Cmd>LispStop<CR>', 'stop image')
    map('<Space>lr', '<Cmd>LispConsole<CR>', 'SBCL console')
    map('<Space>le', call('SendToREPL', 'vlime#ui#CurExprOrAtom()'), 'evaluate form')
    map('<Space>lt', call('SendToREPL', 'vlime#ui#CurTopExpr()'), 'evaluate top-level form')
    map('<Space>le', ':<C-u>call vlime#plugin#SendToREPL(vlime#ui#CurSelection())<CR>', 'evaluate selection', 'x')
    map('<Space>lb', call('Compile', 'vlime#ui#CurTopExpr(v:true)'), 'compile top-level form')
    map('<Space>lf', function()
      vim.cmd.update()
      vim.fn['vlime#plugin#CompileFile'](vim.api.nvim_buf_get_name(0))
    end, 'save, compile and load file')
    map('<Space>li', call('Inspect', 'vlime#ui#CurExprOrAtom()'), 'inspect form')
    map('<Space>lm', call('ExpandMacro', 'vlime#ui#CurExpr(), "one"'), 'macroexpand once')
    map('<Space>ld', call('DescribeSymbol', 'vlime#ui#CurAtom()'), 'describe symbol')
    map('<Space>lh', vim.lsp.buf.signature_help, 'function arguments')
    map('<Space>lx', call('XRefSymbol', '"CALLS", vlime#ui#CurAtom()'), 'callers')
    map('<Space>lg', call('FindDefinition', 'vlime#ui#CurAtom()'), 'Swank definition fallback')
    map('<Space>la', call('SendToREPL'), 'evaluate input / load ASDF system')
    if port(M.root(event.buf), 'vlime') then M.connect(event.buf) end
  end,
})

require('which-key').add { { '<Space>l', group = 'Common Lisp', cond = function() return vim.bo.filetype == 'lisp' end } }
return M
