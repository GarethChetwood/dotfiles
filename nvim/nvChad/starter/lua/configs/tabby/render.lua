local theme = require("configs.tabby.theme")
local path_utils = require("configs.tabby.path")
local fyler = require("configs.tabby.fyler")

local M = {}

function M.render_tab(line, tab)
  local win = tab.current_win()
  local buf = win and win.buf()
  local bufnr = buf and buf.id
  local bufname = bufnr and vim.api.nvim_buf_get_name(bufnr) or ""
  local is_modified = bufnr and vim.bo[bufnr].modified or false
  local buftype = bufnr and vim.bo[bufnr].buftype or ""
  local filetype = bufnr and vim.bo[bufnr].filetype or ""

  local is_fyler = (filetype == "fyler_finder")
  local is_ext = not is_fyler and path_utils.is_external_repo(bufname)

  local hl
  if is_fyler then
    hl = tab.is_current() and theme.current_app or theme.tab_app
  elseif is_ext then
    hl = tab.is_current() and theme.current_ext or theme.tab_ext
  else
    hl = tab.is_current() and theme.current or theme.tab
  end

  local display_name = ""
  local icon_node = ""

  if is_fyler then
    display_name = fyler.get_display_name(tab)
    icon_node = ""
  elseif buftype == "nofile" or filetype == "alpha" then
    display_name = filetype ~= "" and filetype or "[No Name]"
    icon_node = win.file_icon()
  elseif bufname == "" then
    display_name = "[No Name]"
    icon_node = win.file_icon()
  elseif is_ext then
    display_name = vim.fs.normalize(bufname)
    icon_node = win.file_icon()
  else
    display_name = path_utils.get_relative_path(bufname)
    icon_node = win.file_icon()
  end

  return {
    line.sep(" ", hl, theme.fill),
    tostring(tab.number()) .. ":",
    is_ext and " [EXT] " or " ",
    icon_node,
    " " .. display_name,
    (not is_fyler and is_modified) and " [+] " or " ",
    line.sep(" ", hl, theme.fill),
    hl = hl,
  }
end

return M
