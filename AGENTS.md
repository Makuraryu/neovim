# AGENTS.md

本仓库是 Neovim 配置（`~/.config/nvim`），面向 **Neovim 0.12+**，插件管理统一使用内置 **`vim.pack`**。修改配置时请遵循以下约定。

## 插件管理（vim.pack）

- **唯一插件入口**：`lua/plugins/init.lua` 中通过 `vim.pack.add({ ... })` 声明所有插件。
- **使用完整仓库 URL**，例如：`"https://github.com/stevearc/oil.nvim"`（与当前配置保持一致）。
- **新增插件**：
  1. 在 `lua/plugins/init.lua` 的 `vim.pack.add` 列表中添加对应 URL。
  2. 如需配置，新增 `lua/config/<name>.lua`（`require(...).setup(...)`、keymap 等）。
  3. 在 `init.lua` 中 `require("config.<name>")`（放在 `require("plugins")` 之后，确保插件声明已加载）。
- **依赖顺序**：有显式依赖关系的插件需按依赖在前的顺序声明（例如 `blink.cmp` 依赖 `saghen/blink.lib`，应先添加 `blink.lib` 再添加 `blink.cmp`）。
- **不要**引入其他插件管理器（如 lazy.nvim/packer）或并行的插件安装机制，除非用户明确要求迁移。
- `vim.pack.add` 会在启动时确保插件可用；首次添加插件后，建议用无头模式触发安装并检查报错：
  ```bash
  nvim --headless "+qa" 2>&1 | head -120
  ```

## 配置结构

- `init.lua`：基础选项、全局 keymap、按顺序加载 `plugins` 与各 `config.*` 模块。
- `lua/plugins/init.lua`：仅负责 `vim.pack.add` 声明。
- `lua/config/*.lua`：按功能拆分的插件/功能配置（如 `colorscheme.lua`、`lsp.lua`、`statusline.lua`、`oil.lua`）。

## LSP 与补全

- LSP 通过 `nvim-lspconfig` + Neovim 原生 `vim.lsp.config`/`vim.lsp.enable` 配置（见 `lua/config/lsp.lua`）。
- 补全使用 `blink.cmp`，并通过 `blink.get_lsp_capabilities()` 为 LSP 提供能力；当前 fuzzy 实现配置为 `lua`（`fuzzy = { implementation = "lua" }`），避免依赖未构建的原生库。
- 启用具体语言服务器时，先确保系统已安装对应 server，再在 `lua/config/lsp.lua` 中添加/取消注释 `vim.lsp.enable({ ... })`。

## 修改与验证

- 修改后优先做快速语法/加载检查：
  ```bash
  nvim --headless "+lua print('OK')" "+qa"
  ```
- 若涉及新插件，检查输出中 `vim.pack` 安装信息与 Lua 报错；缺少运行时依赖（如 `blink.lib`）时，应补充到 `vim.pack.add` 并调整相关配置。
- 保持改动最小化：仅修改与需求相关的文件与配置块，避免无关重构。
