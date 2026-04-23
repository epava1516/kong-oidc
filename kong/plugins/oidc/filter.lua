local M = {}
local validators = require("kong.plugins.oidc.validators")
local filter_validation_cache = {}

local function get_pattern_validation(pattern)
  local cached = filter_validation_cache[pattern]
  if cached then
    return cached.valid, cached.err
  end

  local valid, err = validators.validate_filter_pattern(pattern)
  filter_validation_cache[pattern] = {
    valid = valid,
    err = err,
  }

  return valid, err
end

local function shouldIgnoreRequest(patterns)
  if (patterns) then
    for _, pattern in ipairs(patterns) do
      local isValid, err = get_pattern_validation(pattern)
      if isValid then
        local ok, match = pcall(string.find, ngx.var.uri, pattern)
        if ok and match ~= nil then
          return true
        end
        if not ok then
          ngx.log(ngx.ERR, "Ignoring invalid oidc filter pattern at runtime: ", pattern)
        end
      else
        ngx.log(ngx.ERR, "Ignoring invalid oidc filter pattern: ", err)
      end
    end
  end
  return false
end

function M.shouldProcessRequest(config)
  return not shouldIgnoreRequest(config.filters)
end

return M
