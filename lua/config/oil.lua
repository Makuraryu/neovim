require("oil").setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ["."] = "actions.toggle_hidden",
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory (Oil)" })
