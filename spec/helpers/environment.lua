local Environment = {}
Environment.__index = Environment

function Environment.new(code, override)
  local self = setmetatable({}, Environment)
  self.code = code
  self.override = override

  return self
end

function Environment:run()
  local exec = loadstring(self.code)
  local env = getfenv(exec)

  for name, obj in pairs(self.override) do
    env[name] = obj
  end

  exec()
  return env
end

return Environment
