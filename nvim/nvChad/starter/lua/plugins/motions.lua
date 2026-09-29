local keys = require("constants.keys")
local get_keys = require("functions.lazy").get_keys

-- Vim motions/controls
local M = {
  {
    "andymass/vim-matchup",  -- Highlight/move to matching bracket/quote
    opts = {
      treesitter = {
        stopline = 500,
      },

    },
    event = "BufEnter",
    keys = { "g%", "[%", "]%", "z%" }
  },

  {
    "arthurxavierx/vim-caser",  -- Commands to re-case selection
    lazy = false,
  },

  {
    "gbprod/substitute.nvim",  -- Replace selection with default register
    keys = { "s", "ss", "S", { "S", mode = "x" }},
    config = function()
      local subst = require("substitute")
      subst.setup()
      vim.keymap.set("n", "s", subst.operator, { desc = "Substitute (With motion)" ,noremap = true })
      vim.keymap.set("n", "ss", subst.line, { desc = "Substitute (Line)" ,noremap = true })
      vim.keymap.set("n", "S", subst.eol, { desc = "Substitute (To end of line)" ,noremap = true })
      vim.keymap.set("x", "S", subst.visual, { desc = "Substitute (Visual selection)" ,noremap = true })
    end
  },

  {
    "tommcdo/vim-exchange",
    keys = { "cx", "cxx", "cxc", "x", "X", { "X", mode = "x" } },
  },

  {
    "Wansmer/treesj",
    keys = { '<space>m', '<space>s' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
    config = function()
      require('treesj').setup({ use_default_keymaps = false })
      vim.keymap.set('n', '<space>m', require('treesj').toggle, { desc = "TreeSJ Toggle" })
      vim.keymap.set('n', '<space>s', require('treesj').split, { desc = "TreeSJ Split" })
    end,
  },

  {
    "nvim-mini/mini.surround",
    config = function()
      require("configs.mini.surround")()
    end,
    lazy = false,
  },

  {
    "aaronik/treewalker.nvim",
    cmd = "Treewalker",
    config = function()
      require("treewalker").setup {}
    end,
  }
}

return M
