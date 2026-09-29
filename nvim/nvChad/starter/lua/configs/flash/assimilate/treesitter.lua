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

--- Prompts Flash jump, extracts the remote AST node, restores cursor, and runs callback(text)
---@param callback fun(text: string)
function M.fetch(callback)
  local flash = require("flash")
  local start_win = vim.api.nvim_get_current_win()
  local start_cursor = vim.api.nvim_win_get_cursor(start_win)

  flash.jump({
    search = { max_length = 2 },
    action = function(match, state)
      local text = M.extract_node_text(match.win, match.pos)
      state:restore()
      vim.api.nvim_set_current_win(start_win)
      vim.api.nvim_win_set_cursor(start_win, start_cursor)

      if text and text ~= "" then
        callback(text)
      end
    end,
  })
end

return M
