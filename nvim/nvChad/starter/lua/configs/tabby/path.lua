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

return M
