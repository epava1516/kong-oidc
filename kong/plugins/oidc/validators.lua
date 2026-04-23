local M = {}

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.validate_recovery_page_path(value)
  if value == nil then
    return true
  end

  if value == "" then
    return false, "must not be empty"
  end

  if value:find("[%c]") then
    return false, "must not contain control characters"
  end

  if value:sub(1, 1) ~= "/" or value:sub(1, 2) == "//" or value:find("://", 1, true) then
    return false, "must be an internal path starting with /"
  end

  return true
end

function M.validate_filter_pattern(value)
  if value == nil then
    return true
  end

  local pattern = trim(value)

  if pattern == "" then
    return false, "must not contain empty patterns"
  end

  if #pattern > 255 then
    return false, "must be 255 characters or fewer"
  end

  if pattern:find("[%c]") then
    return false, "must not contain control characters"
  end

  if pattern:sub(1, 1) ~= "/" and pattern:sub(1, 2) ~= "^/" then
    return false, "must target request paths beginning with /"
  end

  local ok = pcall(string.find, "/oidc-filter-validation", pattern)
  if not ok then
    return false, "contains an invalid Lua pattern"
  end

  return true
end

function M.validate_filter_csv(value)
  if value == nil or value == "" or value == "," then
    return true
  end

  if #value > 2048 then
    return false, "must be 2048 characters or fewer"
  end

  for raw_pattern in string.gmatch(value, "[^,]+") do
    local ok, err = M.validate_filter_pattern(raw_pattern)
    if not ok then
      return false, err
    end
  end

  return true
end

function M.parse_filter_csv(value)
  local patterns = {}

  if value == nil or value == "," then
    return patterns
  end

  for raw_pattern in string.gmatch(value, "[^,]+") do
    local pattern = trim(raw_pattern)
    if pattern ~= "" then
      table.insert(patterns, pattern)
    end
  end

  return patterns
end

return M
