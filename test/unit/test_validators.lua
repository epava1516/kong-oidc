local lu = require("luaunit")
local validators = require("kong.plugins.oidc.validators")

function testRecoveryPagePathValidation()
  local ok = validators.validate_recovery_page_path("/recovery")
  lu.assertTrue(ok)

  ok = validators.validate_recovery_page_path("https://attacker.example")
  lu.assertFalse(ok)

  ok = validators.validate_recovery_page_path("//attacker.example")
  lu.assertFalse(ok)
end

function testRedirectTargetValidation()
  local ok = validators.validate_redirect_target("/cb")
  lu.assertTrue(ok)

  ok = validators.validate_redirect_target("https://attacker.example")
  lu.assertFalse(ok)
end

function testRealmValidation()
  local ok = validators.validate_realm("kong")
  lu.assertTrue(ok)

  ok = validators.validate_realm("kong\r\nInjected: value")
  lu.assertFalse(ok)
end

function testEscapeHttpQuotedString()
  local escaped = validators.escape_http_quoted_string('bad"\r\nrealm', "fallback")
  lu.assertEquals(escaped, 'bad\\"  realm')
end

function testFilterCsvValidation()
  local ok = validators.validate_filter_csv("/health,^/api/")
  lu.assertTrue(ok)

  ok = validators.validate_filter_csv("health")
  lu.assertFalse(ok)

  ok = validators.validate_filter_csv("[")
  lu.assertFalse(ok)
end

lu.run()
