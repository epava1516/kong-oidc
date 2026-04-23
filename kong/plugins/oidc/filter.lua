local M = {}
local validators = require("kong.plugins.oidc.validators")

local function shouldIgnoreRequest(patterns)
  if (patterns) then
    for _, pattern in ipairs(patterns) do
      local isValid, err = validators.validate_filter_pattern(pattern)
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
