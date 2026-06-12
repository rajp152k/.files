vim.g.mapleader = " "
vim.g.maplocalleader = " m"

local opt = vim.opt

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

-- Reload the main Neovim config without restarting.
vim.keymap.set("n", "<leader>R", function()
  vim.cmd.source(vim.env.MYVIMRC)
  vim.notify("Reloaded Neovim config", vim.log.levels.INFO)
end, { desc = "Reload Neovim config" })
