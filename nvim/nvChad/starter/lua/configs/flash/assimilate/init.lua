local M = {}
local ts = require("configs.flash.assimilate.treesitter")
local put = require("configs.flash.assimilate.put")

-- Re-export put methods for convenience
M.put_after = put.after
M.put_before = put.before
M.assimilate_put_after = put.after
M.assimilate_put_before = put.before

local target_ns = vim.api.nvim_create_namespace("assimilate_local_target")
local flash_hl_ns = vim.api.nvim_create_namespace("assimilate_flash_hl")

--- Highlights the local range while jumping and selecting the remote target
local function highlight_local_range(buf, range)
  if not range or not vim.api.nvim_buf_is_valid(buf) then
    return function() end
  end

  vim.api.nvim_buf_clear_namespace(buf, target_ns, 0, -1)
  local hl_group = vim.fn.hlexists("SubstituteRange") == 1 and "SubstituteRange" or "IncSearch"
  pcall(
    vim.highlight.range,
    buf,
    target_ns,
    hl_group,
    { range.start_row, range.start_col },
    { range.end_row, range.end_col }
  )
  vim.cmd("redraw")

  return function()
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_clear_namespace, buf, target_ns, 0, -1)
    end
  end
end

--- Replaces local_range in start_buf with lines and briefly highlights the result
local function replace_local_range(start_win, start_buf, start_cursor, local_range, text, lines)
  if not vim.api.nvim_buf_is_valid(start_buf) then return end
  lines = lines or vim.split(text or "", "\n")
  if #lines == 0 then return end

  vim.api.nvim_buf_set_text(
    start_buf,
    local_range.start_row,
    local_range.start_col,
    local_range.end_row,
    local_range.end_col,
    lines
  )

  if vim.api.nvim_win_is_valid(start_win) then
    vim.api.nvim_set_current_win(start_win)
    ts.restore_cursor(start_win, start_cursor[1], start_cursor[2])
  end

  local end_row = local_range.start_row + #lines - 1
  local end_col = (#lines == 1)
    and (local_range.start_col + #lines[1])
    or #lines[#lines]

  local hl_group = vim.fn.hlexists("YankHighlight") == 1 and "YankHighlight" or "IncSearch"
  pcall(
    vim.highlight.range,
    start_buf,
    flash_hl_ns,
    hl_group,
    { local_range.start_row, local_range.start_col },
    { end_row, end_col }
  )
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(start_buf) then
      pcall(vim.api.nvim_buf_clear_namespace, start_buf, flash_hl_ns, 0, -1)
    end
  end, 350)
end

--- Assimilate (Normal Mode): Select local target via motion, then Flash jump & select remote target via motion/visual
function M.assimilate()
  local start_win = vim.api.nvim_get_current_win()
  local start_buf = vim.api.nvim_get_current_buf()
  local start_cursor = vim.api.nvim_win_get_cursor(start_win)
  local start_view = vim.fn.winsaveview()

  _G._assimilate_local_op = function(motion_type)
    local local_range = ts.get_operator_range(start_buf, motion_type)
    if not local_range then return end

    if vim.api.nvim_win_is_valid(start_win) then
      vim.api.nvim_win_call(start_win, function()
        if start_view then pcall(vim.fn.winrestview, start_view) end
      end)
      ts.restore_cursor(start_win, start_cursor[1], start_cursor[2])
    end

    local clear_hl = highlight_local_range(start_buf, local_range)

    vim.schedule(function()
      ts.fetch(function(text, lines)
        clear_hl()
        replace_local_range(start_win, start_buf, start_cursor, local_range, text, lines)
      end, function()
        clear_hl()
      end)
    end)
  end

  vim.go.operatorfunc = "v:lua._assimilate_local_op"
  vim.api.nvim_feedkeys("g@", "n", false)
end

--- Assimilate (Visual Mode): Replace local visual selection with remote motion/visual selection via Flash
function M.assimilate_visual()
  local start_win = vim.api.nvim_get_current_win()
  local start_buf = vim.api.nvim_get_current_buf()
  local local_range = ts.get_visual_range(start_buf)
  if not local_range then return end

  local start_cursor = { local_range.start_row + 1, local_range.start_col }
  vim.cmd("normal! \27")

  local clear_hl = highlight_local_range(start_buf, local_range)

  vim.schedule(function()
    ts.fetch(function(text, lines)
      clear_hl()
      replace_local_range(start_win, start_buf, start_cursor, local_range, text, lines)
    end, function()
      clear_hl()
    end)
  end)
end

-- Backwards-compatible aliases
M.assimilate_treesitter = M.assimilate
M.assimilate_visual_treesitter = M.assimilate_visual

return M
