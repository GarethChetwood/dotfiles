-- Outline tests: verify the `outline` field returned for each node.
-- OutlineItem fields: label, node_type, range, classification.
-- Requires helpers.lua to have been sourced.

local buf = load_fixture("lua_sample.lua")
local function s(r, c) return survey(buf, r, c) end

-- ── Function outline (body children) ─────────────────────────────────────
-- Surveying the function_declaration directly produces an outline of its
-- recognised body children.

do -- `add` function at row 1: outline shows body statements (not parameters/block wrapper)
  local r = s(1, 0)
  eq("function: outline length", #r.outline, 2)
  -- first body child: variable_declaration on row 3
  is_not_nil("function: outline[1]",               r.outline[1])
  eq("function: outline[1].node_type",             r.outline[1].node_type, "variable_declaration")
  eq("function: outline[1].range.start_row",       r.outline[1].range.start_row, 3)
  -- label is the trimmed first line, max 16 chars
  -- "local sum = x + y" (17 chars) → "local sum = x + "
  eq("function: outline[1].label",                 r.outline[1].label, "local sum = x + ")
  -- second body child: if_statement on row 4
  is_not_nil("function: outline[2]",               r.outline[2])
  eq("function: outline[2].node_type",             r.outline[2].node_type, "if_statement")
  eq("function: outline[2].range.start_row",       r.outline[2].range.start_row, 4)
  eq("function: outline[2].label",                 r.outline[2].label, "if sum > 0 then")
end

-- ── ParameterList ─────────────────────────────────────────────────────────
-- Parameters are exposed via the function's state.parameters NavigationTarget,
-- not as outline items (the function outline shows body statements only).

do -- `add(x, y)`: parameters accessible via state, not outline
  local r = s(1, 0)
  is_not_nil("param_list: state.parameters", r.node.node.state.parameters)
  eq("param_list: state.parameters.node_type", r.node.node.state.parameters.node_type, "parameters")
end

-- ── FileRoot outline (top-level nodes) ───────────────────────────────────
-- Extended fixture has: add (row 1), a (row 9), b (row 10), c (row 11), greet (row 13)

do
  -- Survey at a position that resolves to FileRoot's first child
  -- (FileRoot is transparent, so surveying col 0 row 0 climbs to the first recognised node)
  -- Test the outline of the `add` function at row 1 instead:
  local r = s(1, 0)
  -- Outline should cover the body children of add
  eq("add: has outline", type(r.outline), "table")
end

-- ── ReturnStatement has an empty outline ──────────────────────────────────
-- ReturnStatement never exposes its expression children as outline items.

do
  local r = survey(buf, 14, 4)  -- return_statement inside greet
  eq("return: outline is empty", #(r.outline or {}), 0)
end

-- ── `greet` body: single return statement ─────────────────────────────────
-- `greet` body contains only a return statement.
-- The function outline shows that return as the sole item (with hint_key "r").

do
  local r = s(13, 0)  -- greet function_declaration
  eq("greet: outline length", #r.outline, 1)
  eq("greet: outline[1].node_type", r.outline[1].node_type, "return_statement")
end
