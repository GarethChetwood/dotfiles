local M = {}

function M.setup(opts)
  opts = opts or {}

  local flash = require("flash")
  flash.setup(vim.tbl_deep_extend("force", {
    highlight = { backdrop = false },
  }, opts))

end

return M
