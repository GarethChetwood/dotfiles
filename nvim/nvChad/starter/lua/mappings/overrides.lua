local switch_window = require("functions.mappings").switch_window

-- Mappings that deliberately replace built-in Vim/Neovim behaviour.
-- The comment on each group says what default is being given up.
local M = {}

M.overrides = {
    n = {
        -- Window switching: these skip "locked" windows (e.g. the Fyler sidebar,
        -- see `locked_filetypes` in functions/mappings.lua), which instead have
        -- their own dedicated focus key (<C-b> for Fyler).
        --
        -- <Tab> replaces the default <Tab>/<C-i> (jump forward in the jumplist).
        ["<Tab>"] = {switch_window("w"), "Switch to next window"},
        ["<S-Tab>"] = {switch_window("W"), "Switch to previous window"},
        -- The following replace the built-in <C-w> window-movement commands.
        ["<C-w>w"] = {switch_window("w"), "Switch to next window"},
        ["<C-w><C-w>"] = {switch_window("w"), "Switch to next window"},
        ["<C-w>W"] = {switch_window("W"), "Switch to previous window"},
        ["<C-w>h"] = {switch_window("h"), "Switch to left window"},
        ["<C-w>j"] = {switch_window("j"), "Switch to window below"},
        ["<C-w>k"] = {switch_window("k"), "Switch to window above"},
        ["<C-w>l"] = {switch_window("l"), "Switch to right window"},

        -- Default <C-w><C-v>: vertical split (same as <C-w>v).
        ["<C-w><C-v>"] = {"<cmd> vert sb # <CR>", "Open a vertical split of current and previous buffer"},
        -- Default <C-w><C-t>: go to the top-left window.
        ["<C-w><C-t>"] = {"<cmd> tabc <CR>", "Close tab"},
        -- Default <C-t>: pop the tag stack.
        ["<C-t>"] = {"<cmd> tabnew | Alpha <CR>", "Open new tab and run Alpha (dashboard)"},

        -- Default Y: yank to end of line (y$).
        ["Y"] = {"^vg_", "select line (excluding EOL character)"},
    },
}

return M
