local function gh(repo) return 'https://github.com/' .. repo end

-- Interactive evaluation for JavaScript (and other REPL-friendly languages).
-- For JS, Conjure starts `node` over stdio and sends forms/ranges from your buffer.
-- Open a .js file and run `:ConjureSchool` or `:help conjure-client-javascript-stdio`.
vim.g['conjure#client#javascript#stdio#command'] = 'node'
vim.g['conjure#mapping#doc_word'] = false -- keep K/hover behavior available for LSP
vim.g['conjure#log#hud#enabled'] = true
vim.g['conjure#log#hud#width'] = 0.42
vim.g['conjure#log#hud#height'] = 0.32

vim.pack.add { gh 'Olical/conjure' }

vim.keymap.set('n', '<leader>cs', '<cmd>ConjureSchool<cr>', { desc = '[C]onjure [S]chool' })
vim.keymap.set('n', '<leader>cl', '<cmd>ConjureLogVSplit<cr>', { desc = '[C]onjure [L]og' })

-- vim: ts=2 sts=2 sw=2 et
