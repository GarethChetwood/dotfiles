local M = {}
local ts = require("configs.flash.assimilate.treesitter")

--- Snapshots the put/clipboard registers and returns an idempotent restore function
function M.create_register_guard()
  local saved = {
    unnamed = { vim.fn.getreg('"'), vim.fn.getregtype('"') },
    yank0   = { vim.fn.getreg('0'), vim.fn.getregtype('0') },
    clip    = { vim.fn.getreg('+'), vim.fn.getregtype('+') },
  }

  local restored = false
  local function restore()
    if restored then return end
    restored = true
    pcall(vim.fn.setreg, '"', saved.unnamed[1], saved.unnamed[2])
    pcall(vim.fn.setreg, '0', saved.yank0[1], saved.yank0[2])
    pcall(vim.fn.setreg, '+', saved.clip[1], saved.clip[2])
  end

  return restore
end

--- Inserts text directly at cursor via nvim_put without touching any registers
---@param text string The text to insert
---@param after boolean true for put after ('p'), false for put before ('P')
function M.put_text(text, after)
  if not text or text == "" then return end
  local lines = vim.split(text, "\n")
  vim.api.nvim_put(lines, "c", after, true)
end

--- Pull Tree-sitter node and paste AFTER cursor
function M.after()
  ts.fetch(function(text)
    M.put_text(text, true)
  end)
end

--- Pull Tree-sitter node and paste BEFORE cursor
function M.before()
  ts.fetch(function(text)
    M.put_text(text, false)
  end)
end

-- Aliases for flexibility
M.assimilate_put_after = M.after
M.assimilate_put_before = M.before

return M
