local lu = require("luaunit")

TestSession = require("test.unit.mockable_case"):extend()

function TestSession:setUp()
  TestSession.super:setUp()
end

function TestSession:tearDown()
  TestSession.super:tearDown()
end

function TestSession:test_configure_sets_plain_secret_when_nginx_var_exists()
  local session = require("kong.plugins.oidc.session")

  ngx.var.session_secret = ""
  session.configure({ session_secret = "plain-text-secret" })

  lu.assertEquals(ngx.var.session_secret, "plain-text-secret")
end

function TestSession:test_configure_skips_when_nginx_var_missing()
  local session = require("kong.plugins.oidc.session")

  ngx.var.session_secret = nil
  session.configure({ session_secret = "plain-text-secret" })

  lu.assertNil(ngx.var.session_secret)
end

lu.run()
