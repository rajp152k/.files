-- Clojure editing and interactive evaluation.
vim.pack.add {
  { src = 'https://github.com/Olical/conjure', version = 'b23c76a8c874fe7ac5ad95255efc66173b049088' },
}

local mini_pairs = require 'mini.pairs'

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('ClojureDevelopment', { clear = true }),
  pattern = 'clojure',
  callback = function(event)
    local buf = event.buf
    mini_pairs.map_buf(buf, 'i', '(', { action = 'open', pair = '()' })
    mini_pairs.map_buf(buf, 'i', ')', { action = 'close', pair = '()' })
    mini_pairs.map_buf(buf, 'i', '[', { action = 'open', pair = '[]' })
    mini_pairs.map_buf(buf, 'i', ']', { action = 'close', pair = '[]' })
    mini_pairs.map_buf(buf, 'i', '{', { action = 'open', pair = '{}' })
    mini_pairs.map_buf(buf, 'i', '}', { action = 'close', pair = '{}' })
    mini_pairs.map_buf(buf, 'i', '"', {
      action = 'closeopen',
      pair = '""',
      neigh_pattern = '^[^\\\\]',
      register = { cr = false },
    })
    vim.opt_local.matchpairs = '(:),[:],{:}'
    vim.opt_local.showmatch = true
  end,
})
