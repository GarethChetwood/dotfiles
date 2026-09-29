-- Neovim core functionality
local M = {
  {
    "nathom/filetype.nvim",  -- Speed up startup time
  },

  {
    "max397574/better-escape.nvim", -- Avoid delays before resolving hotkey chains
    config = function()
      require("better_escape").setup({
        timeout = 200,
        mappings = {
          -- Normal-mode chords, overriding j/k (see mappings/overrides.lua).
          -- The first key has already moved the cursor, so each chord starts
          -- by reversing it before running the action.
          n = {
            j = { k = "k<Cmd>lua require('flash').jump({ search = { max_length = 2 } })<CR>" },
            k = { j = "j<Cmd>lua require('flash').treesitter()<CR>" },
          },
        },
      })
    end,
    event = "VeryLazy", -- not InsertEnter: the normal-mode chords must exist from the start
  },

  {
    "mg979/vim-visual-multi",  -- Multi cursor
    config = function()
      require "configs.vim-visual-multi"
    end
  },

  {
    "gbprod/stay-in-place.nvim",  -- Prevent cursor moving when searching/filtering
    event = "BufEnter",
  },

  {
    "tpope/vim-repeat"  -- Press "." (dot) to repeat last action
  },

  {
    "tomarrell/vim-npr",  -- Follow a file path/url
  },

  {
    "ofirgall/open.nvim",  -- Open a file or Github link
      keys = {"n","gx"},
      config = function()
        require('open').setup {
        }
        vim.keymap.set('n', 'gx', require('open').open_cword)
      end,
  }
}

return M
