local M = {}

-- Sourced directly from active colorscheme / highlights
local theme = {
  fill = "TabLineFill",
  current = "TabLineSel",
  tab = "TabLine",
  current_ext = "TabLineExternalSel",
  tab_ext = "TabLineExternal",
  current_app = "TabLineAppSel",
  tab_app = "TabLineApp",
}

local function is_external_repo(bufpath)
  if not bufpath or bufpath == "" then return false end
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local norm_path = vim.fs.normalize(bufpath)

  -- Check if file is outside current working directory
  local is_outside_cwd = not vim.startswith(norm_path:lower(), (cwd .. "/"):lower()) and norm_path:lower() ~= cwd:lower()

  -- Check if file belongs to a different git repository
  local current_git = vim.fs.root(cwd, { ".git" })
  local file_git = vim.fs.root(bufpath, { ".git" })
  local is_diff_repo = (current_git and file_git and current_git:lower() ~= file_git:lower())

  return is_outside_cwd or is_diff_repo
end

local function get_fyler_display_name(tab)
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
    local rel_path = vim.fs.normalize(vim.fn.fnamemodify(editor_bufname, ":."))
    return string.format("[Fyler] %s (%s)", rel_path, cwd_name)
  else
    return string.format("[Fyler] (%s)", cwd_name)
  end
end

function M.setup()
  require("tabby").setup({
    line = function(line)
      return {
        line.tabs().foreach(function(tab)
          local win = tab.current_win()
          local buf = win and win.buf()
          local bufnr = buf and buf.id
          local bufname = bufnr and vim.api.nvim_buf_get_name(bufnr) or ""
          local is_modified = bufnr and vim.bo[bufnr].modified or false
          local buftype = bufnr and vim.bo[bufnr].buftype or ""
          local filetype = bufnr and vim.bo[bufnr].filetype or ""

          local is_fyler = (filetype == "fyler_finder")
          local is_ext = not is_fyler and is_external_repo(bufname)

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
            display_name = get_fyler_display_name(tab)
            icon_node = ""
          elseif buftype == "nofile" or filetype == "alpha" then
            display_name = filetype ~= "" and filetype or "[No Name]"
            icon_node = win.file_icon()
          elseif bufname == "" then
            display_name = "[No Name]"
            icon_node = win.file_icon()
          else
            display_name = vim.fs.normalize(bufname)
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
        end),
        line.spacer(),
        hl = theme.fill,
      }
    end,
  })
end

return M
