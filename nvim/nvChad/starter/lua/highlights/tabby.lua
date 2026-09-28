local M = {}

M.override = {
  TabLine = {
    fg = "light_grey",
    bg = "statusline_bg",
  },
  TabLineSel = {
    fg = "white",
    bg = "one_bg",
    bold = true,
  },
  TabLineFill = {
    bg = "statusline_bg",
  },
}

M.add = {
  TabLineExternal = {
    fg = "red",
    bg = "statusline_bg",
  },
  TabLineExternalSel = {
    fg = "red",
    bg = "one_bg",
    bold = true,
  },
  TabLineApp = {
    fg = "purple",
    bg = "statusline_bg",
  },
  TabLineAppSel = {
    fg = "purple",
    bg = "one_bg",
    bold = true,
  },
}

return M
