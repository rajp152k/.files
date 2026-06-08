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

-- Plugins
require("config.lazy")
