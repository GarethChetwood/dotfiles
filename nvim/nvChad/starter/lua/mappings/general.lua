local current_file_dir = require("functions.mappings").current_file_dir
local explore_current_file_dir = require("functions.mappings").explore_current_file_dir
local return_to_dashboard = require("functions.mappings").return_to_dashboard
local flick_command = require("functions.scroll-flick").flick_command

local M = {}

M.general = {
    [{"n", "i"}] = {
        ["<C-p>"] = { "<cmd> Telescope find_files<CR>", "Find files" },
        ["<C-Tab>"] = {"<cmd> tabnext <CR>", "Switch to next tab"},
        ["<C-S-Tab>"] = {"<cmd> tabprev <CR>", "Switch to previous tab"},

        -- buffers
        ["<leader><TAB>"] = {"<cmd> bnext <CR>", "Next buffer"},
        ["<leader><S-TAB>"] = {"<cmd> bprevious <CR>", "Prev buffer"},
        ["<leader>x"] = {"<cmd> b#|bd# <CR>", "Delete buffer (but keep current window)"},
        ["<leader>X"] = {"<cmd> bd <CR>", "Delete buffer and window"},
        ["<leader>wc"] = {"<cmd> :clo <CR>", "Delete window only"},
    },
    n = {
        ["<Esc>"] = {"<cmd>noh<CR><Esc>", "Clear highlights and escape"},

        -- Meta stuff
        ["<leader>lzs"] = {"<cmd> Lazy sync <CR>", "Sync plugins"},

        -- Current directory
        ["<leader>cd"] = {"<cmd> :cd %:p:h <CR>", "Set directory to current file's"},
        ["<leader>ycd"] = {function()
            vim.fn.setreg("*", current_file_dir())
        end, "Yank current file directory to clipboard"},
        ["<leader>ecd"] = {explore_current_file_dir, "Open explorer at current file's directory (windows)"},

        -- Dashboards & project files
        ["ZW"] = {"<cmd> wa <CR>", "Save all files"},
        ["ZD"] = {return_to_dashboard(false), "Return to project dashboard"},
        ["ZDQ"] = {return_to_dashboard(true), "Return to dashboard"},
        ["ZA"] = {"<cmd> wa | qa <CR>", "Save all files then quit vim"},
        ["Zs"] = {"<cmd>so %<CR>", "Source current file"},

        -- Tab/window switching: see mappings/overrides.lua

        -- Scrolling
        ["<C-S-g>"] = {flick_command("2.15"), "Jump ↑ by ½ screen"},
        ["<C-S-h>"] = {flick_command("-2.15"), "Jump ↓ by ½ screen"},
        ["<C-S-j>"] = {flick_command("0.75"), "Jump ↑ by ¼ screen"},
        ["<C-S-k>"] = {flick_command("-0.75"), "Jump ↓ by ¼ screen"},

        -- Editing
        ["<leader><CR>"] = { "O<Esc>O<Esc>ji", "Insert mode with new line above and below" },
        ["<leader>i"] = { "i  <Left>", "Insert mode with space around" },

        -- Info
        ["gh"] = { function() vim.lsp.buf.hover() end, "Open LSP hover menu" },

        -- Diagnostics
        ["]d"] = {function()
            vim.diagnostic.goto_next()
        end, "Go to next diagnostic issue"},
        ["[d"] = {function()
            vim.diagnostic.goto_prev()
        end, "Go to previous diagnostic issue"}
    },
    i = {
        -- Symbols
        ["<space>="] = {" = ", "spaced equals"},
        ["<space>>="] = {" >= ", "spaced greater than or equal to"},
        ["<space><="] = {" <= ", "spaced less than or equal to"},
        ["<space><space>="] = {" == ", "spaced equality"},
        ["<space><space>>"] = {" => ", "spaced arrow operator"},
        ["<space>{"] = {"{  }<left><left>", "spaced curly braces"},
        ["<space>["] = {"[  ]<left><left>", "spaced square braces"}
    },
    c = {},
    v = {
        ["<leader>/sa"] = {'y:%s/<C-R>"//g<left><left>', "Replace selection on all lines."},
        ["<leader>/sc"] = {'y:%s/<C-R>"//gc<left><left><left>', "Replace selection on all lines (with confirmation)."},
        ["<leader>/sl"] = {'y:s/<C-R>"//g<left><left>', "Replace selection on current line."}
    },
    x = {
        ["il"] = {"g_o^", "Select inner line"}
    },
    o = {
        ["il"] = {"<cmd>:normal vil<CR>", "Text object: inner line"}
    }
}

return M
