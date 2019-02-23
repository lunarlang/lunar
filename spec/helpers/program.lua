local Program = {}
Program.__index = Program

function Program.new(code, override)
  local self = setmetatable({}, Program)
  self.code = code
  self.override = override

  return self
end

function Program:run()
  local exec = loadstring(self.code)
  local env = getfenv(exec)

  for name, obj in pairs(self.override) do
    env[name] = obj
  end

  local result = { exec() }
  return { env = env, result = result }
end

return Program
