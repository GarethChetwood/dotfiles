local M = {}

M.override = {
  CursorLine = {
    bg = "black2",
  },
  Comment = {
    italic = true,
    fg = "grey_fg",
  },
  ["@comment"] = {
    italic = true,
    fg = "grey_fg",
  },
}

local searchHighlight = function(isCurrent)
  local fg_col = "black"
  local bg_col = "purple"
  local isBold = false
  if isCurrent then
    bg_col = "dark_purple"
    isBold = true
  end
  return { fg = fg_col, bg = bg_col, bold = isBold }
end

M.add = {
  CurSearch = searchHighlight(true),
  IncSearch = searchHighlight(true),
  Search = searchHighlight(false),
  Substitute = { fg = "black", bg = "sun", bold = true },
  YankHighlight = { fg = "#dddddd", bg = "one_bg3" },
  VisualMultiCursor = { fg = "grey_fg2", bg = "dark_purple" },
  InsertModeCursor = { fg = "black", bg = "sun" },
  VisualModeCursor = { fg = "black", bg = "dark_purple" },
}

return M
