local Symbol = {}
Symbol.__index = {}

function Symbol.constructor(self, name)
  self.name = name
  self.is_referenced = false
  self.is_assigned = false
  self.declaration = nil -- Node or nil

  self.members = nil -- SymbolTable or nil; should include class and interface instance members
  self.exports = nil -- SymbolTable or nil; should include class statics, as well as module exports
end

Symbol.__tostring = function(self)
  return "Symbol ('" .. tostring(self.name) .. "')"
end

function Symbol.new(...)
  local self = setmetatable({}, Symbol)
  Symbol.constructor(self, ...)
  return self
end

return Symbol