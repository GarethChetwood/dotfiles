local M = {}

--- Expands a raw leaf token (like 'name' in 'data.name') up to its full meaningful expression
function M.get_meaningful_node(node)
  if not node then return nil end

  -- 1. If on a string fragment, expand to the full string literal
  local t = node:type()
  if t == "string_fragment" or t == "string_content" or t == "escape_sequence" then
    if node:parent() and (node:parent():type():match("string") or node:parent():type() == "template_string") then
      node = node:parent()
    end
  end

  -- 2. Walk up from leaf identifiers/properties to complete expressions / access chains
  while node:parent() do
    local p = node:parent()
    local p_type = p:type()

    if p_type == "member_expression"          -- JS/TS: data.name
       or p_type == "field_expression"        -- Rust/C: data.name
       or p_type == "attribute"               -- Python: data.name
       or p_type == "selector_expression"     -- Go: data.Name
       or p_type == "dot_index_expression"    -- Lua: data.name
       or p_type == "subscript_expression"    -- JS/TS: data[0]
       or p_type == "subscript"               -- Python: data[0]
       or p_type == "index_expression"        -- Go/Rust: data[0]
       or p_type == "scoped_identifier"       -- Rust/C++: std::name
       or p_type == "nested_identifier"       -- C++: a::b
    then
      node = p
    elseif p_type == "jsx_attribute" and node:type() == "property_identifier" then
      -- If targeting the prop name in <Component prop={val} />, grab the whole prop={val}
      node = p
      break
    else
      break
    end
  end

  return node
end

--- Extracts the Tree-sitter node or text at the target position
function M.extract_node_text(win, pos)
  local bufnr = vim.api.nvim_win_get_buf(win)
  local row, col = pos[1] - 1, pos[2]

  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col } })
  if ok and node then
    node = M.get_meaningful_node(node)
    local text = vim.treesitter.get_node_text(node, bufnr)
    if text and text ~= "" then
      return text
    end
  end

  -- Fallback: word at position if treesitter is not available
  local lines = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)
  local line = lines[1] or ""
  local word = line:sub(col + 1):match("^[%w_]+")
  if word and word ~= "" then
    return word
  end

  return line:sub(col + 1, col + 1)
end

--- Prompts Flash jump, exits Flash immediately, and captures a remote motion/text-object (or visual selection)
---@param callback fun(text: string, lines: string[])
---@param on_cancel? fun()
function M.fetch(callback, on_cancel)
  local flash = require("flash")
  local start_win = vim.api.nvim_get_current_win()
  local start_cursor = vim.api.nvim_win_get_cursor(start_win)
  local start_view = vim.fn.winsaveview()

  local target_win, target_pos

  flash.jump({
    search = { max_length = 2 },
    action = function(match, state)
      target_win = match.win
      target_pos = match.pos
      state:restore()
      state:hide()
    end,
  })

  if not target_win or not target_pos or not vim.api.nvim_win_is_valid(target_win) then
    if on_cancel then on_cancel() end
    return
  end

  vim.schedule(function()
    if not vim.api.nvim_win_is_valid(target_win) then
      if on_cancel then on_cancel() end
      return
    end

    local target_buf = vim.api.nvim_win_get_buf(target_win)
    local remote_cursor, remote_view
    if target_win ~= start_win then
      remote_cursor = vim.api.nvim_win_get_cursor(target_win)
      vim.api.nvim_win_call(target_win, function()
        remote_view = vim.fn.winsaveview()
      end)
    end

    vim.api.nvim_set_current_win(target_win)
    vim.api.nvim_win_set_cursor(target_win, target_pos)

    local ns = vim.api.nvim_create_namespace("assimilate_remote_cursor")
    vim.api.nvim_buf_clear_namespace(target_buf, ns, 0, -1)
    pcall(vim.api.nvim_buf_set_extmark, target_buf, ns, target_pos[1] - 1, target_pos[2], {
      end_row = target_pos[1] - 1,
      end_col = target_pos[2] + 1,
      hl_group = "IncSearch",
    })
    vim.cmd("redraw")

    local augroup = vim.api.nvim_create_augroup("AssimilateRemoteOp", { clear = true })
    local completed = false
    local entering_visual = false
    local restored = false

    local function restore_all()
      if restored then return end
      restored = true
      pcall(vim.api.nvim_del_augroup_by_id, augroup)
      if vim.api.nvim_buf_is_valid(target_buf) then
        pcall(vim.api.nvim_buf_clear_namespace, target_buf, ns, 0, -1)
        pcall(vim.keymap.del, "o", "v", { buffer = target_buf })
        pcall(vim.keymap.del, "o", "V", { buffer = target_buf })
        pcall(vim.keymap.del, "x", "<CR>", { buffer = target_buf })
        pcall(vim.keymap.del, "x", "ga", { buffer = target_buf })
        pcall(vim.keymap.del, "x", "y", { buffer = target_buf })
        pcall(vim.keymap.del, "x", "<Esc>", { buffer = target_buf })
      end

      if target_win ~= start_win and vim.api.nvim_win_is_valid(target_win) then
        vim.api.nvim_win_call(target_win, function()
          if remote_view then pcall(vim.fn.winrestview, remote_view) end
        end)
        if remote_cursor then
          pcall(vim.api.nvim_win_set_cursor, target_win, remote_cursor)
        end
      end

      if vim.api.nvim_win_is_valid(start_win) then
        vim.api.nvim_set_current_win(start_win)
        vim.api.nvim_win_call(start_win, function()
          if start_view then pcall(vim.fn.winrestview, start_view) end
        end)
        M.restore_cursor(start_win, start_cursor[1], start_cursor[2])
      end
    end

    _G._assimilate_remote_op = function(motion_type)
      if completed then return end
      completed = true
      local range = M.get_operator_range(target_buf, motion_type)
      local text, lines = M.get_range_text(target_buf, range)
      restore_all()
      if text and text ~= "" then
        callback(text, lines)
      elseif on_cancel then
        on_cancel()
      end
    end

    local function start_visual(vis_key)
      entering_visual = true

      local function confirm_visual()
        if completed then return end
        completed = true
        local range = M.get_visual_range(target_buf)
        local text, lines = M.get_range_text(target_buf, range)
        vim.cmd("normal! \27")
        restore_all()
        if text and text ~= "" then
          callback(text, lines)
        elseif on_cancel then
          on_cancel()
        end
      end

      local function cancel_visual()
        if completed then return end
        completed = true
        vim.cmd("normal! \27")
        restore_all()
        if on_cancel then on_cancel() end
      end

      vim.keymap.set("x", "<CR>", confirm_visual, { buffer = target_buf, nowait = true, silent = true })
      vim.keymap.set("x", "ga", confirm_visual, { buffer = target_buf, nowait = true, silent = true })
      vim.keymap.set("x", "y", confirm_visual, { buffer = target_buf, nowait = true, silent = true })
      vim.keymap.set("x", "<Esc>", cancel_visual, { buffer = target_buf, nowait = true, silent = true })

      vim.api.nvim_create_autocmd("ModeChanged", {
        group = augroup,
        pattern = "[vV\x16]*:[^vV\x16]*",
        once = true,
        callback = function()
          vim.schedule(function()
            if not completed then
              completed = true
              restore_all()
              if on_cancel then on_cancel() end
            end
          end)
        end,
      })

      return "<Esc>" .. vis_key
    end

    vim.keymap.set("o", "v", function()
      return start_visual("v")
    end, { buffer = target_buf, expr = true, nowait = true, silent = true })

    vim.keymap.set("o", "V", function()
      return start_visual("V")
    end, { buffer = target_buf, expr = true, nowait = true, silent = true })

    vim.api.nvim_create_autocmd("ModeChanged", {
      group = augroup,
      pattern = "no*:n",
      once = true,
      callback = function()
        vim.schedule(function()
          if not completed and not entering_visual then
            completed = true
            restore_all()
            if on_cancel then on_cancel() end
          end
        end)
      end,
    })

    vim.go.operatorfunc = "v:lua._assimilate_remote_op"
    vim.api.nvim_feedkeys("g@", "n", false)
  end)
end

--- Clamps and sets cursor on a window without throwing out-of-bounds errors
function M.restore_cursor(win, row, col)
  if not vim.api.nvim_win_is_valid(win) then return end
  local buf = vim.api.nvim_win_get_buf(win)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local safe_row = math.min(math.max(1, row), line_count)
  local line = vim.api.nvim_buf_get_lines(buf, safe_row - 1, safe_row, false)[1] or ""
  local max_col = math.max(0, #line - 1)
  local safe_col = math.min(math.max(0, col), max_col)
  pcall(vim.api.nvim_win_set_cursor, win, { safe_row, safe_col })
end

--- Computes 0-indexed start/end row and byte col from operator '[' and ']' marks
function M.get_operator_range(buf, motion_type)
  if not vim.api.nvim_buf_is_valid(buf) then return nil end
  local s = vim.api.nvim_buf_get_mark(buf, "[")
  local e = vim.api.nvim_buf_get_mark(buf, "]")
  local s_row, s_col = s[1] - 1, s[2]
  local e_row, e_col = e[1] - 1, e[2]

  if s_row < 0 or e_row < 0 then return nil end

  if s_row > e_row or (s_row == e_row and s_col > e_col) then
    s_row, e_row = e_row, s_row
    s_col, e_col = e_col, s_col
  end

  local end_line = vim.api.nvim_buf_get_lines(buf, e_row, e_row + 1, false)[1] or ""
  if motion_type == "line" then
    s_col = 0
    e_col = #end_line
  else
    if e_col < #end_line then
      local char_idx = vim.fn.charidx(end_line, e_col)
      local next_byte = (char_idx >= 0) and vim.fn.byteidx(end_line, char_idx + 1) or -1
      e_col = (next_byte ~= -1) and next_byte or #end_line
    else
      e_col = #end_line
    end
  end

  local start_line = vim.api.nvim_buf_get_lines(buf, s_row, s_row + 1, false)[1] or ""
  s_col = math.min(math.max(0, s_col), #start_line)

  return {
    start_row = s_row,
    start_col = s_col,
    end_row = e_row,
    end_col = e_col,
  }
end

--- Computes 0-indexed start/end row and byte col from active visual selection
function M.get_visual_range(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return nil end
  local s = vim.fn.getpos("v")
  local e = vim.fn.getpos(".")
  local s_row, s_col = s[2] - 1, s[3] - 1
  local e_row, e_col = e[2] - 1, e[3] - 1

  if s_row > e_row or (s_row == e_row and s_col > e_col) then
    s_row, e_row = e_row, s_row
    s_col, e_col = e_col, s_col
  end

  local mode = vim.fn.mode()
  local end_line = vim.api.nvim_buf_get_lines(buf, e_row, e_row + 1, false)[1] or ""
  if mode == "V" then
    s_col = 0
    e_col = #end_line
  else
    if e_col < #end_line then
      local char_idx = vim.fn.charidx(end_line, e_col)
      local next_byte = (char_idx >= 0) and vim.fn.byteidx(end_line, char_idx + 1) or -1
      e_col = (next_byte ~= -1) and next_byte or #end_line
    else
      e_col = #end_line
    end
  end

  local start_line = vim.api.nvim_buf_get_lines(buf, s_row, s_row + 1, false)[1] or ""
  s_col = math.min(math.max(0, s_col), #start_line)

  return {
    start_row = s_row,
    start_col = s_col,
    end_row = e_row,
    end_col = e_col,
  }
end

--- Returns concatenated string and lines array for a range in buf
function M.get_range_text(buf, range)
  if not range or not vim.api.nvim_buf_is_valid(buf) then return nil, nil end
  local lines = vim.api.nvim_buf_get_text(
    buf,
    range.start_row,
    range.start_col,
    range.end_row,
    range.end_col,
    {}
  )
  return table.concat(lines, "\n"), lines
end

return M
