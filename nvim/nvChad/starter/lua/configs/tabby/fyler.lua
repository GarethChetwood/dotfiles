local path_utils = require("configs.tabby.path")

local M = {}

function M.get_display_name(tab)
  local editor_bufname = ""

  -- Find the non-Fyler editor window in the tab
  for _, w in ipairs(tab.wins().wins) do
    local b = w.buf()
    local b_id = b and b.id
    if b_id and vim.bo[b_id].filetype ~= "fyler_finder" and vim.bo[b_id].buftype ~= "nofile" then
      local name = vim.api.nvim_buf_get_name(b_id)
      if name ~= "" then
        editor_bufname = name
        break
      end
    end
  end

  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local cwd_name = vim.fs.basename(cwd) or cwd

  if editor_bufname ~= "" then
    local rel_path = path_utils.get_relative_path(editor_bufname)
    return string.format("[Fyler] %s (%s)", rel_path, cwd_name)
  else
    return string.format("[Fyler] (%s)", cwd_name)
  end
end

return M
