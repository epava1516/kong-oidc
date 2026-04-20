local validators = {}

function validators.set_system_leeway(_)
end

function validators.equals(expected)
  return function(value)
    return value == expected
  end
end

function validators.required()
  return function(value)
    return value ~= nil
  end
end

function validators.is_not_expired()
  return function(_)
    return true
  end
end

function validators.opt_is_not_before()
  return function(_)
    return true
  end
end

return validators
