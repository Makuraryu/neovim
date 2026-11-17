local starter = require("mini.starter")

local ns_recent = vim.api.nvim_create_namespace("user_starter_recent")

local function decorate_item_hook(content)
  for _, line in ipairs(content) do
    for i, unit in ipairs(line) do
      if unit.type == "item" and unit.item and unit.item._icon then
        local icon = unit.item._icon
        unit.string = (unit.string:gsub("^" .. vim.pesc(icon), ""))
        local icon_unit = {
          string = icon,
          type = "item_icon",
          hl = "MiniStarterItem",
          _item = unit.item,
          _place_cursor = false,
        }
        line[i] = icon_unit
        table.insert(line, i + 1, unit)

        break
      end
    end
  end
  return content
end

local function recent_location(path)
  local dir = vim.fs.dirname(path)
  if dir == "." or dir == "" then
    return nil
  end
  local parts = vim.split(dir, "/", { plain = true, trimempty = true })
  if #parts == 0 then
    return nil
  end
  local n = math.min(2, #parts)
  local tail = {}
  for j = #parts - n + 1, #parts do
    tail[#tail + 1] = parts[j]
  end
  return table.concat(tail, "/")
end

local function bracket_name(name)
  return name
end

local function actions_section()
  local items = {}

  table.insert(items, {
    name = bracket_name("Files"),
    action = "Oil",
    section = "Actions",
    _icon = "󰉋  ",
    _bracket_label = true,
  })

  local builtin_icons = {
    ["Edit new buffer"] = "󰈔  ",
    ["Quit Neovim"] = "󰈆  ",
  }
  for _, item in ipairs(starter.sections.builtin_actions()) do
    item.section = "Actions"
    item._icon = builtin_icons[item.name]
    item.name = bracket_name(item.name)
    item._bracket_label = true
    table.insert(items, item)
  end

  return items
end

local function recent_files_section()
  local files = {}
  for _, f in ipairs(vim.v.oldfiles or {}) do
    if vim.fn.filereadable(f) == 1 then
      table.insert(files, f)
      if #files >= 5 then
        break
      end
    end
  end

  if #files == 0 then
    return {
      {
        name = "There are no recent files (`v:oldfiles` is empty)",
        action = "",
        section = "Recent files",
      },
    }
  end

  local items = {}
  for i, f in ipairs(files) do
    local fname = vim.fn.fnamemodify(f, ":t")
    table.insert(items, {
      name = tostring(i) .. " " .. fname,
      action = "edit " .. vim.fn.fnameescape(f),
      section = "Recent files",
      _icon = "  ",
      _bracket_label = true,
      _recent_path = vim.fn.fnamemodify(f, ":p"),
      _recent_index = i,
    })
  end
  return items
end

local function update_recent_virtual_text(buf_id)
  if not (buf_id and vim.api.nvim_buf_is_valid(buf_id)) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf_id, ns_recent, 0, -1)

  local ok_data, data = pcall(function()
    return require("mini.starter").get_content(buf_id)
  end)
  if not ok_data or not data then
    return
  end

  local win = vim.fn.bufwinid(buf_id)
  if win == -1 then
    return
  end
  local cursor = vim.api.nvim_win_get_cursor(win)
  local lnum = cursor[1] - 1
  local line = data[cursor[1]]
  if not line then
    return
  end

  local col = 0
  for _, unit in ipairs(line) do
    local item = unit.item or unit._item
    local s = unit.string or ""
    if unit.type == "item" and item and item._recent_path then
      local loc = recent_location(item._recent_path)
      if loc then
        local _, p = s:find("^%d+ ")
        local fname_col = col + (p or 0)
        vim.api.nvim_buf_set_extmark(buf_id, ns_recent, lnum, fname_col, {
          virt_text = { { loc .. "/", "Comment" } },
          virt_text_pos = "inline",
        })
      end
      return
    end
    col = col + #s
  end
end

local function post_refresh(buf_id)
  buf_id = buf_id or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf_id) then
    return
  end
  if vim.bo[buf_id].filetype ~= "ministarter" then
    return
  end

  update_recent_virtual_text(buf_id)
end

local function quote_hook(content)
  table.insert(content, { { string = "", type = "empty", hl = nil } })
  table.insert(content, { { string = "「Brevity Is the Soul of Wit.」", type = "section", hl = "MiniStarterSection" } })
  return content
end

starter.setup({
  header = table.concat({
    " ▐ ▄ ▄▄▄ .       ▌ ▐·▪  • ▌ ▄ ·.",
    "•█▌▐█▀▄.▀·▪     ▪█·█▌██ ·██ ▐███▪",
    "▐█▐▐▌▐▀▀▪▄ ▄█▀▄ ▐█▐█•▐█·▐█ ▌▐▌▐█·",
    "██▐█▌▐█▄▄▌▐█▌.▐▌ ███ ▐█▌██ ██▌▐█▌",
    "▀▀ █▪ ▀▀▀  ▀█▄▀▪. ▀  ▀▀▀▀▀  █▪▀▀▀",
  }, "\n"),
  items = {
    actions_section,
    recent_files_section,
  },
  content_hooks = {
    starter.gen_hook.adding_bullet("  ", false),
    decorate_item_hook,
    quote_hook,
    starter.gen_hook.aligning("center", "center"),
  },
  footer = "",
})

local orig_refresh = starter.refresh
starter.refresh = function(buf_id, ...)
  orig_refresh(buf_id, ...)
  post_refresh(buf_id)
end

local orig_update = starter.update_current_item
starter.update_current_item = function(direction, buf_id, ...)
  orig_update(direction, buf_id, ...)
  update_recent_virtual_text(buf_id or vim.api.nvim_get_current_buf())
end

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniStarterOpened",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= "ministarter" then
      return
    end
    for i = 1, 9 do
      local key = tostring(i)
      vim.keymap.set("n", key, function()
        local b = vim.api.nvim_get_current_buf()
        starter.set_query(key, b)
      end, { buffer = buf, nowait = true, silent = true, desc = "Jump to recent " .. key })
    end
    vim.keymap.set("n", "-", "<cmd>Oil<cr>", { buffer = buf, nowait = true, silent = true })
  end,
})
