local overrides = require("configs.overrides")

-- UI
local M = { {
  "nvim-telescope/telescope-fzf-native.nvim",
  build =
  "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  lazy = false,
  config = function()
    require("telescope").load_extension "fzf"
  end
}, {
  "nvim-telescope/telescope-ui-select.nvim",
  -- dependencies = "nvim-telescope/telescope.nvim",
  lazy = false,
  config = function()
    require('telescope').load_extension('ui-select')
  end
},
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = function()
      require("configs.flash").setup()
    end,
  },
  {
    "anuvyklack/hydra.nvim",
    event = "VeryLazy",
    config = function()
      require("configs.hydra").setup()
    end,
  },
  -- Restore last quit buffer
  {
    "AndrewRadev/undoquit.vim",
    cmd = "Undoquit",
    config = function()
      vim.g.undoquit_mapping = ""
      vim.g.undoquit_tab_mapping = ""
    end
  },

  -- Close all OTHER buffers
  {
    "numToStr/BufOnly.nvim",
    cmd = "BufOnly"
  },
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gedit", "Gsplit", "Gread", "Gwrite", "Ggrep", "Glgrep", "Gmove",
      "Gdelete", "Gremove", "Gbrowse" }
  },
  {
    'goolord/alpha-nvim',
    lazy = false,
    config = overrides.alpha
  },
  {
    'Gazareth/alpha-omega-nvim',
    lazy = false,
    config = overrides.alpha_omega
  },
  {
    name = "atlantis-surveyor",
    enabled = false,
    dir = vim.fs.joinpath(vim.fn.expand("X:/Development/dotfiles"), "nvim", "myPlugins", "atlantis-surveyor"),
    lazy = false,
    build = vim.fn.has("win32") == 1
        and "powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1"
        or "chmod +x build.sh && ./build.sh",
    config = function()
      vim.api.nvim_create_user_command("SurveyorNode", function()
        local s = require("atlantis_surveyor")
        vim.print(s.node(0, vim.fn.line(".") - 1, vim.fn.col(".") - 1))
      end, {
        desc = "Atlantis surveyor: print node at cursor",
      })

      vim.api.nvim_create_user_command("AtlantisNouveau", function()
        require("configs.hydra.atlantis_nouveau").open()
      end, {
        desc = "Atlantis Nouveau: open node menu at cursor",
      })

    end,
  },
  { "mbbill/undotree" }, -- Access different undo "timelines"
  {
    "nanozuki/tabby.nvim",
    lazy = false,
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("configs.tabby").setup()
    end,
  },
  {
    "b0o/incline.nvim", -- Floating file name label per window
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = require("configs.incline").opts,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = false, -- use floating popup for search
        command_palette = true, -- center the cmdline and popupmenu together
        long_message_to_split = true, -- send long messages to a split buffer
        lsp_doc_border = true, -- add rounded borders to hover docs & signature help
      },
    },
  },
}

return M

