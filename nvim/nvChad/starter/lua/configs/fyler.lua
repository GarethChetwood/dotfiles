function open_fyler () 
  return require("fyler").open()
end

local M = {
  opts = {
    kind = "floating",
    follow_current_file = true,
    integrations = {
      icon = 'nvim_web_devicons'
    },
    mappings = {
      n = {
        ['<C-b>'] = {
          action = 'close',
        },
      },
    },
  },
  keys = {
    { "<C-b>", open_fyler, desc = "Open Fyler View" },
  },
}

return M
