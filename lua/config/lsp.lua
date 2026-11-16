-- Completion (blink.cmp)
local blink = require("blink.cmp")
blink.setup({
  keymap = { preset = "default" },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lsp", "path", "buffer" },
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  fuzzy = { implementation = "lua" },
})

-- LSP configuration (nvim-lspconfig + Neovim 0.11+ vim.lsp.config)
local capabilities = blink.get_lsp_capabilities()

-- Apply blink capabilities to all LSP servers
vim.lsp.config("*", {
  capabilities = capabilities,
})

-- Enable servers you have installed, e.g.:
-- vim.lsp.enable({ "lua_ls", "pyright", "ts_ls" })

-- Useful LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
  end,
})
