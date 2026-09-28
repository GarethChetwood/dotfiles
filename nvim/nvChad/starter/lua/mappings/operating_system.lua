local M = {}

M.operating_system = {
    [{"n", "v", "i"}] = {
        ["<C-s>"] = {"<cmd> w <CR>", "Save file"},
    },
    [{"n", "v"}] = {
        ["<C-v>"] = {'"+p', "Paste from clipboard"},
    },
    v = {
        ["<C-c>"] = {'"+y', "Copy selection to clipboard"},
        ["<C-x>"] = {'"+d', "Cut selection to clipboard"},
    },
    n = {
        ["<C-a>"] = {"ggVG", "Select all"},
        ["<C-z>"] = {"u", "Undo"},
        ["<C-y>"] = {"<C-r>", "Redo"},
        ["<C-S-z>"] = {"<C-r>", "Redo"},
    },
    i = {
        ["<C-v>"] = {"<C-r><C-o>+", "Paste from clipboard"},
        ["<C-z>"] = {"<ESC>ui", "Undo"},
    },
    c = {
        ["<C-v>"] = {"<C-r>+", "Paste from clipboard"},
    },
}

return M
