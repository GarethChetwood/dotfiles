local function open_fyler(args)
  return function()
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file ~= "" then
      vim.fn.setreg("#", current_file)
    end

    require("fyler").open(args or {})
  end
end

-- Sidebar width tracks the current font size ((3 + fontsize)%), read at open time so
-- Neovide zoom changes are picked up. Falls back to 25% outside Neovide.
local function sidebar_width()
  local font_size = vim.g.neovide_font_size
  return font_size and ((3 + font_size) .. "%") or "25%"
end

-- Fyler windows are skipped by normal window switching, so this is the way in:
-- focus the sidebar if it's already open in this tab, otherwise open it.
local function focus_or_open_sidebar()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "fyler_finder" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  open_fyler({ kind = "split_left_most", width = sidebar_width() })()
end

local M = {
  keys = {
    { "<leader>b", open_fyler(), desc = "Open Fyler View" },
    { "<C-b>", focus_or_open_sidebar, desc = "Focus/Open Fyler View - Sidebar" },
  },
  opts = {
    kind = "floating",
    follow_current_file = true,
    integrations = {
      icon = 'nvim_web_devicons'
    },
    kind_presets = {
      split_left = { width = '25%' },
      split_left_most = { width = '25%' },
    },
    mappings = {
      n = {
        ['<C-b>'] = {
          action = 'close',
        },
      },
    },
  },
}

return M
