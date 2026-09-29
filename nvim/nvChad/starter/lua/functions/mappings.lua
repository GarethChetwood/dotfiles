local M = {}

-- Windows that normal window switching skips over (use their dedicated keys to focus them)
M.locked_filetypes = {
  NvimTree = true,
  fyler_finder = true,
}

-- Dashboard/Settings shortcuts
M.switch_window = function(command)
  return function()
    local start_win = vim.api.nvim_get_current_win()
    for _ = 1, vim.fn.winnr("$") do
      vim.cmd("wincmd " .. command)
      local win = vim.api.nvim_get_current_win()
      if not M.locked_filetypes[vim.bo.filetype] then
        return
      end
      if win == start_win then
        break
      end
    end
    -- Only locked windows in that direction: stay put
    vim.api.nvim_set_current_win(start_win)
  end
end

M.current_file_dir = function()
  return vim.fn.expand "%:p:h"
end

M.explore_current_file_dir = function()
  if vim.g.is_windows then
    local escaped_file_path = M.current_file_dir():gsub("\\", "\\\\")
    local command = '!"explorer.exe \'' .. escaped_file_path .. "'\""
    vim.cmd(command)
  else
    vim.cmd("open " .. M.current_file_dir())
  end
end

M.return_to_dashboard = function(set_cd)
  return function()
    vim.cmd "tabonly | enew | BufOnly"
    vim.cmd "Alpha"
    if set_cd then
      local current_type = vim.bo.filetype
      if current_type ~= "alpha" and #current_type ~= 0 then
        vim.cmd "CdHome"
      end
    end
    -- Exit current project
    require("projections.switcher"):set_current()
  end
end

return M
