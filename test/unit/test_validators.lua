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

function testFilterCsvValidation()
  local ok = validators.validate_filter_csv("/health,^/api/")
  lu.assertTrue(ok)

  ok = validators.validate_filter_csv("health")
  lu.assertFalse(ok)

  ok = validators.validate_filter_csv("[")
  lu.assertFalse(ok)
end

lu.run()
