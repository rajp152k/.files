vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- Use a dark, terminal-driven appearance.
-- We do not install a colorscheme; let the terminal provide the palette/background.
opt.background = "dark"
opt.termguicolors = true

local function use_terminal_background()
  local groups = {
    "Normal",
    "NormalNC",
    "SignColumn",
    "EndOfBuffer",
    "LineNr",
    "CursorLineNr",
    "FoldColumn",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end
end

use_terminal_background()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = use_terminal_background,
})

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Toggle word wrap in the current window/buffer.
vim.keymap.set("n", "<leader>w", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle word wrap" })

-- Reload the main Neovim config without restarting.
vim.keymap.set("n", "<leader>R", function()
  vim.cmd.source(vim.env.MYVIMRC)
  vim.notify("Reloaded Neovim config", vim.log.levels.INFO)
end, { desc = "Reload Neovim config" })

-- Plugins
require("config.lazy")
