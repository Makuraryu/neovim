-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.completeopt = "menu,menuone,noselect"
vim.opt.shortmess:append("I")

-- Move by visual/display lines when no count is given
local function visual_move(key, gkey)
  return function()
    return vim.v.count == 0 and gkey or key
  end
end

for _, mode in ipairs({ "n", "v", "o" }) do
  vim.keymap.set(mode, "j", visual_move("j", "gj"), { expr = true, silent = true, desc = "Down (visual line)" })
  vim.keymap.set(mode, "k", visual_move("k", "gk"), { expr = true, silent = true, desc = "Up (visual line)" })
  vim.keymap.set(mode, "<Down>", visual_move("j", "gj"), { expr = true, silent = true, desc = "Down (visual line)" })
  vim.keymap.set(mode, "<Up>", visual_move("k", "gk"), { expr = true, silent = true, desc = "Up (visual line)" })
end

vim.keymap.set("i", "<Down>", "<C-o>gj", { silent = true, desc = "Down (visual line)" })
vim.keymap.set("i", "<Up>", "<C-o>gk", { silent = true, desc = "Up (visual line)" })

-- Leader keymaps
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

require("plugins")
require("config.colorscheme")
require("config.lsp")
require("config.statusline")
require("config.starter")
require("config.oil")
require("config.copilot")
