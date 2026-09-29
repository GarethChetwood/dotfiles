local M = {}

function M.is_external_repo(bufpath)
  if not bufpath or bufpath == "" then return false end
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local norm_path = vim.fs.normalize(bufpath)

  local current_git = vim.fs.root(cwd, { ".git" })
  local file_git = vim.fs.root(bufpath, { ".git" })

  if current_git then
    local norm_git = vim.fs.normalize(current_git)
    if file_git and vim.fs.normalize(file_git):lower() ~= norm_git:lower() then
      return true
    end
    local is_inside_git = vim.startswith(norm_path:lower(), (norm_git .. "/"):lower()) or norm_path:lower() == norm_git:lower()
    return not is_inside_git
  end

  local is_inside_cwd = vim.startswith(norm_path:lower(), (cwd .. "/"):lower()) or norm_path:lower() == cwd:lower()
  return not is_inside_cwd
end

function M.get_relative_path(bufpath)
  if not bufpath or bufpath == "" then return "[No Name]" end
  local norm_path = vim.fs.normalize(bufpath)
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local git_root = vim.fs.root(cwd, { ".git" })
  local root = git_root and vim.fs.normalize(git_root) or cwd

  local rel = vim.fs.normalize(vim.fn.fnamemodify(bufpath, ":."))
  if rel ~= "" and rel ~= "." and not vim.startswith(rel, "../") and not vim.startswith(rel, "/") and not rel:find("^[a-zA-Z]:") then
    return rel
  end

  if git_root then
    local root_prefix = root .. "/"
    if vim.startswith(norm_path:lower(), root_prefix:lower()) then
      local path_in_git = norm_path:sub(#root_prefix + 1)
      if path_in_git ~= "" then
        return path_in_git
      end
    end
  end

  return rel ~= "" and rel or vim.fs.basename(norm_path)
end

-- Files whose name alone says little, so their folder is shown as part of the name
local generic_stems = { init = true, index = true, __init__ = true, mod = true }

-- "a/b/c/file.lua" -> "file.lua", "a/b/c"; "a/b/c/init.lua" -> "c/init.lua", "a/b"
-- dir is "" when there's nothing left to show
function M.split_display(path)
  local dir, file = path:match("^(.*)/([^/]+)$")
  if not dir then return path, "" end

  local stem = file:match("^(.-)%.") or file
  if generic_stems[stem] then
    local parent_dir, parent = dir:match("^(.*)/([^/]+)$")
    file = (parent or dir) .. "/" .. file
    dir = parent_dir or ""
  end

  return file, dir
end

-- "a/b/c/file.lua" -> "file.lua [a/b/c]", "a/b/c/init.lua" -> "c/init.lua [a/b]"
function M.format_display(path)
  local file, dir = M.split_display(path)
  return dir ~= "" and string.format("%s [%s]", file, dir) or file
end

-- Path to show for a buffer: relative to the project, or absolute if it's outside it
function M.display_path(bufname)
  if M.is_external_repo(bufname) then
    return vim.fs.normalize(bufname), true
  end
  return M.get_relative_path(bufname), false
end

return M
