local M = {}
local ts = require("configs.flash.assimilate.treesitter")
local put = require("configs.flash.assimilate.put")

-- Re-export put methods for convenience
M.put_after = put.after
M.put_before = put.before
M.assimilate_put_after = put.after
M.assimilate_put_before = put.before

--- Ensures substitute.nvim is loaded
local function get_substitute()
  local ok, substitute = pcall(require, "substitute")
  if not ok then
    pcall(function()
      require("lazy").load({ plugins = { "substitute.nvim" } })
    end)
    substitute = require("substitute")
  end
  return substitute
end

--- Replaces target with text using substitute.nvim while guarding registers
---@param text string The replacement text
---@param is_visual boolean true for visual mode, false for operator-pending motion
local function substitute_with(text, is_visual)
  local restore = put.create_register_guard()
  vim.fn.setreg("z", text)

  if is_visual then
    vim.cmd("normal! gv")
    get_substitute().visual({ register = "z" })
    restore()
  else
    local text_changed_id, cancel_id
    text_changed_id = vim.api.nvim_create_autocmd("TextChanged", {
      once = true,
      callback = function()
        pcall(vim.api.nvim_del_autocmd, cancel_id)
        restore()
      end,
    })
    cancel_id = vim.api.nvim_create_autocmd("ModeChanged", {
      pattern = "*:n",
      once = true,
      callback = function()
        vim.schedule(function()
          pcall(vim.api.nvim_del_autocmd, text_changed_id)
          restore()
        end)
      end,
    })

    get_substitute().operator({ register = "z" })
  end
end

--- Assimilate (Normal Mode): Pull Tree-sitter node and substitute local motion
function M.assimilate_treesitter()
  ts.fetch(function(text)
    substitute_with(text, false)
  end)
end

--- Assimilate (Visual Mode): Overwrite visual selection with remote Tree-sitter node
function M.assimilate_visual_treesitter()
  vim.cmd('normal! \27') -- Save '< and '> visual marks
  ts.fetch(function(text)
    substitute_with(text, true)
  end)
end

return M
