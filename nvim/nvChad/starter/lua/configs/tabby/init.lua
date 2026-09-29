local theme = require("configs.tabby.theme")
local render = require("configs.tabby.render")

local M = {}

function M.setup()
  require("tabby").setup({
    line = function(line)
      return {
        line.tabs().foreach(function(tab)
          return render.render_tab(line, tab)
        end),
        line.spacer(),
        hl = theme.fill,
      }
    end,
  })
end

return M
