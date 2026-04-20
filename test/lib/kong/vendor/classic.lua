local Object = {}
Object.__index = Object

function Object:extend()
  local cls = {}

  for key, value in pairs(self) do
    if key:find("__") == 1 then
      cls[key] = value
    end
  end

  cls.__index = cls
  cls.super = self
  setmetatable(cls, {
    __index = self,
    __call = function(c, ...)
      local instance = setmetatable({}, c)
      if instance.new then
        instance:new(...)
      end
      return instance
    end
  })

  return cls
end

setmetatable(Object, {
  __call = function(c, ...)
    local instance = setmetatable({}, c)
    if instance.new then
      instance:new(...)
    end
    return instance
  end
})

return Object
