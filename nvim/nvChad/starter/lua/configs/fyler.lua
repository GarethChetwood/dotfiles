local fyler = require("fyler")

local M = {
  opts = {
    follow_current_file = true,
    mappings = {
      ["<C-b>"] = "CloseView",
    },
    integrations = {
      icon = "nvim_web_devicons",
    },
  },
  keys = {
    { "<C-b>", fyler.open(), desc = "Open Fyler View" },
  },
}

return M
