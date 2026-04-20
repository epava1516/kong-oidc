local M = {}

function M.configure(config)
  if config.session_secret and ngx.var and ngx.var.session_secret ~= nil then
    ngx.var.session_secret = config.session_secret
  end
end

return M
