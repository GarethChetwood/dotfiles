local overrides = require("configs.overrides")

-- Cosmetic
local M = {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("monokai-pro").setup({
        filter = "ristretto",
      })
      vim.schedule(function()
        -- Load monokai-pro highlights directly over NvChad's defaults
        require("monokai-pro.theme").load()

        -- Force specific overrides bypassing the cache completely
        local p = require("monokai-pro.palette").load("ristretto")
        vim.api.nvim_set_hl(0, "@type.enum", { fg = p.text })
        vim.api.nvim_set_hl(0, "@property.enum", { fg = p.accent6 })
        vim.api.nvim_set_hl(0, "@constant.enum", { fg = p.accent6 })
        vim.api.nvim_set_hl(0, "@variable.member.enum", { fg = p.accent6 })
        vim.api.nvim_set_hl(0, "@variable.import", { fg = p.text })
        vim.api.nvim_set_hl(0, "@module", { fg = p.text })
      end)
    end,
  },
  {
    "echasnovski/mini.cursorword", -- Highlight all instances of the word under the cursor
    event = "BufEnter ",
    version = false,
    config = function()
      require('mini.cursorword').setup()
    end
  },

  {
    "lukas-reineke/indent-blankline.nvim", -- Show indentation levels
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = overrides.blankline,
  },

  {
    "beauwilliams/focus.nvim", -- Dynamically resize splits to focus on current one
    version = false,
    lazy = false,
    config = function()
      require("focus").setup({
        autoresize = {
          enable = true,
          minwidth = 20, -- keep unfocused windows visible, rather than squashing a neighbour to 1 column
        },
      })

      -- Replace eager 'Resize splits' WinEnter autocmd with a deferred version
      -- so buffers have time to initialize filetype and b:focus_disable before Focus measures them
      for _, ac in ipairs(vim.api.nvim_get_autocmds({ group = "Focus", event = "WinEnter" })) do
        if ac.desc == "Resize splits" then
          vim.api.nvim_del_autocmd(ac.id)
        end
      end

      vim.api.nvim_create_autocmd("WinEnter", {
        group = "Focus",
        callback = function()
          vim.schedule(function()
            require("focus").resize()
          end)
        end,
        desc = "Deferred focus.nvim resize allowing filetype resolution",
      })
    end,
  },

  {
    "rlychrisg/truncateline.nvim", -- Hints at offscreen text when horizontally scrolling
    enabled = false
  },

  {
    "folke/zen-mode.nvim",
    cmd = { "ZenMode" },
    config = function()
      require("zen-mode").setup {
        window = {
          width = .75
        }
      }
    end
  },

  {
    "folke/twilight.nvim", -- Dim other sections of code
    cmd = { "Twilight", "TwilightEnable", "TwilightDisable" }
  },

  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton"
  }
}

return M
