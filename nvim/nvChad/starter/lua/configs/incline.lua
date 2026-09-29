local path_utils = require("functions.path")

local M = {}

-- Floating label in the top-right of each window: "icon name [+]"
local function render(props)
  local bufname = vim.api.nvim_buf_get_name(props.buf)
  if bufname == "" then
    return { { "[No Name]", group = "Comment" } }
  end

  local path, is_ext = path_utils.display_path(bufname)
  local file = path_utils.split_display(path) -- name only; tabby shows the full path
  local icon, icon_color = require("nvim-web-devicons").get_icon_color(bufname)

  return {
    icon and { icon, " ", guifg = props.focused and icon_color or nil } or "",
    is_ext and { "[EXT] ", group = "WarningMsg" } or "",
    { file, gui = props.focused and "bold" or nil },
    vim.bo[props.buf].modified and { " [+]", group = "DiagnosticWarn" } or "",
  }
end

M.opts = {
  render = render,
  window = {
    margin = { horizontal = 1, vertical = 0 },
  },
  ignore = {
    filetypes = { "fyler_finder", "alpha" },
  },
}

return M
