local function setup()
  local core = require("configs.mini.surround.core")
  local tags = require("configs.mini.surround.tags")

  local opts = vim.deepcopy(core.opts)
  opts.custom_surroundings = vim.tbl_deep_extend(
    "force",
    opts.custom_surroundings or {},
    tags.custom_surroundings or {}
  )

  require("mini.surround").setup(opts)
  tags.setup()
end

return setup
