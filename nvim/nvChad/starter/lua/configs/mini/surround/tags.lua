local M = {}

-- Cached JSX / HTML tag: { left = "<div ...>", right = "</div>" }
M.last_tag = nil

-- Helper to find the enclosing tag element (JSX or HTML) using Tree-sitter
local function get_enclosing_tag_element()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then
    return nil
  end

  while node do
    local t = node:type()
    if t == "jsx_element" or t == "jsx_fragment" or t == "element" then
      return node
    end
    node = node:parent()
  end
  return nil
end

-- Check if the current MiniSurround action is "replace" (e.g. cst)
local function is_replace_action()
  local level = 2
  while true do
    local info = debug.getinfo(level, "nS")
    if not info then break end
    if info.name == "replace" then
      return true
    end
    level = level + 1
  end
  return false
end

local function handle_tag_input()
  local element = get_enclosing_tag_element()
  if not element then
    -- Fallback to default mini.surround tag regex patterns
    return { "<(%w-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }
  end

  local open_node, close_node
  for child in element:iter_children() do
    local t = child:type()
    if t == "jsx_opening_element" or t == "jsx_opening_fragment" or t == "start_tag" then
      open_node = child
    elseif t == "jsx_closing_element" or t == "jsx_closing_fragment" or t == "end_tag" then
      close_node = child
    end
  end

  if not open_node or not close_node then
    return { "<(%w-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }
  end

  local open_text = vim.treesitter.get_node_text(open_node, 0)
  local close_text = vim.treesitter.get_node_text(close_node, 0)

  -- Cache for 'yst' and also save to register "t"
  M.last_tag = {
    left = open_text,
    right = close_text,
  }
  pcall(vim.fn.setreg, "t", open_text)

  local tag_name = open_text:match("^<%s*([%w%.-]+)") or "tag"
  vim.notify("Cut <" .. tag_name .. "> (ready to wrap with 'yst')")

  local or1, oc1, or2, oc2 = open_node:range()
  local cr1, cc1, cr2, cc2 = close_node:range()

  -- If called from 'cs' (replace), let mini.surround handle standard replacement
  if is_replace_action() then
    return {
      left = {
        from = { line = or1 + 1, col = oc1 + 1 },
        to = { line = or2 + 1, col = oc2 },
      },
      right = {
        from = { line = cr1 + 1, col = cc1 + 1 },
        to = { line = cr2 + 1, col = cc2 },
      },
    }
  end

  -- Delete action: check if opening and closing tags are on their own lines (linewise)
  local buf = 0
  local line_open_1 = vim.api.nvim_buf_get_lines(buf, or1, or1 + 1, false)[1] or ""
  local line_open_2 = vim.api.nvim_buf_get_lines(buf, or2, or2 + 1, false)[1] or ""
  local is_open_alone = line_open_1:sub(1, oc1):match("^%s*$") ~= nil
    and line_open_2:sub(oc2 + 1):match("^%s*$") ~= nil

  local line_close_1 = vim.api.nvim_buf_get_lines(buf, cr1, cr1 + 1, false)[1] or ""
  local line_close_2 = vim.api.nvim_buf_get_lines(buf, cr2, cr2 + 1, false)[1] or ""
  local is_close_alone = line_close_1:sub(1, cc1):match("^%s*$") ~= nil
    and line_close_2:sub(cc2 + 1):match("^%s*$") ~= nil

  if is_open_alone and is_close_alone and or2 < cr1 then
    -- Linewise delete: delete entire lines to prevent leaving blank lines
    -- 1. Delete closing tag line(s) first
    vim.api.nvim_buf_set_lines(buf, cr1, cr2 + 1, false, {})
    -- 2. Delete opening tag line(s)
    vim.api.nvim_buf_set_lines(buf, or1, or2 + 1, false, {})

    -- 3. Dedent inner lines
    local inner_start = or1
    local num_open_lines = or2 - or1 + 1
    local inner_end = cr1 - num_open_lines - 1
    if inner_start <= inner_end then
      pcall(vim.cmd, string.format("silent! %d,%d<", inner_start + 1, inner_end + 1))
    end

    -- Return an empty region (to = nil) so mini.surround doesn't delete extra text
    return {
      left = { from = { line = inner_start + 1, col = 1 }, to = nil },
      right = { from = { line = inner_start + 1, col = 1 }, to = nil },
    }
  else
    -- Inline delete (e.g. <span>text</span>)
    vim.api.nvim_buf_set_text(buf, cr1, cc1, cr2, cc2, {})
    vim.api.nvim_buf_set_text(buf, or1, oc1, or2, oc2, {})

    return {
      left = { from = { line = or1 + 1, col = oc1 + 1 }, to = nil },
      right = { from = { line = or1 + 1, col = oc1 + 1 }, to = nil },
    }
  end
end

M.custom_surroundings = {
  ["t"] = {
    input = handle_tag_input,
    output = function()
      if M.last_tag then
        local tag = M.last_tag
        M.last_tag = nil
        return tag
      end
      local tag_name = MiniSurround.user_input("Tag")
      return tag_name and { left = "<" .. tag_name .. ">", right = "</" .. tag_name .. ">" } or nil
    end,
  },
}

function M.setup()
  -- Native mini.surround integration
end

return M
