local M = {}

M.override = {
  St_NormalMode = {
    bg = "white",
  },
  St_InsertMode = {
    bg = "yellow",
  },
  St_TerminalMode = {
    bg = "blue",
  },
  St_NTerminalMode = {
    bg = "blue",
  },
  St_VisualMode = {
    bg = "dark_purple",
  },
  St_ReplaceMode = {
    bg = "orange",
  },
  St_ConfirmMode = {
    bg = "teal",
  },
  St_CommandMode = {
    bg = "red",
  },
  St_SelectMode = {
    bg = "dark_purple",
  },

  St_NormalModeSep = {
    fg = "white",
  },

  St_InsertModeSep = {
    fg = "yellow",
  },

  St_TerminalModeSep = {
    fg = "blue",
  },

  St_NTerminalModeSep = {
    fg = "blue",
  },

  St_VisualModeSep = {
    fg = "dark_purple",
  },

  St_ReplaceModeSep = {
    fg = "orange",
  },

  St_ConfirmModeSep = {
    fg = "teal",
  },

  St_CommandModeSep = {
    fg = "red",
  },

  St_SelectModeSep = {
    fg = "dark_purple",
  },

  St_EmptySpace = {},

  St_file_sep = {
    fg = "lightbg",
    bg = "one_bg",
  },
}

M.add = {
  St_file_modified = {
    bg = "lightbg",
    fg = "white",
    bold = true,
  },
  St_file_folder_info = {
    fg = "white",
    bg = "one_bg",
  },
  St_folder_sep = {
    fg = "one_bg",
    bg = "statusline_bg",
  },
  St_folder_head = {
    fg = "lighter_grey",
    bg = "one_bg",
  },
  St_folder_chevs = {
    fg = "light_grey",
    bg = "one_bg",
    bold = true,
  },
  St_file_git_sep = {
    fg = "black2",
    bg = "statusline_bg",
  },
  St_LspAttachedName = {
    fg = "dark_purple",
    bold = true,
  },
  St_cwd_project = {
    fg = "lighter_grey",
    bg = "lightbg",
  },
}

return M
