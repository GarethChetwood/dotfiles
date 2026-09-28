-- To find any highlight groups: "<cmd> Telescope highlights"
-- Each highlight group can take a table with variables fg, bg, bold, italic, etc
-- base30 variable names can also be used as colors

local M = {
  override = {},
  add = {},
}

local modules = {
  require("highlights.general"),
  require("highlights.statusline"),
  require("highlights.indent_blankline"),
  require("highlights.tabby"),
}

for _, mod in ipairs(modules) do
  if mod.override then
    M.override = vim.tbl_deep_extend("force", M.override, mod.override)
  end
  if mod.add then
    M.add = vim.tbl_deep_extend("force", M.add, mod.add)
  end
end

return M
