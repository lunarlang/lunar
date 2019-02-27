local SymbolTable = require "lunar.compiler.semantic.symbol_table"

local Scope = {}
Scope.__index = {}

function Scope.constructor(self, level, parent, env)
  self.level = level
  self.parent = parent
  if not parent then
    self.env = env
  end
  self.symbol_table = SymbolTable.new()
end

function Scope.__index:get_value(name)
  return self.symbol_table:get_value(name) or (self.parent and self.parent:get_value(name)) or self.env.globals:get_value(name)
end

function Scope.__index:get_type(name)
  return self.symbol_table:get_type(name) or (self.parent and self.parent:get_type(name)) or self.env.globals:get_type(name)
end

function Scope.__index:has_value(name)
  return self.symbol_table:has_value(name) or (self.parent and self.parent:has_value(name)) or self.env.globals:has_value(name)
end

function Scope.__index:has_type(name)
  return self.symbol_table:has_type(name) or (self.parent and self.parent:has_type(name)) or self.env.globals:has_type(name)
end

function Scope.__index:has_level_value(name)
  local base_scope = self
  repeat
    if self.symbol_table:has_value(name) then
      return true
    end
    base_scope = base_scope.parent
  until not base_scope or base_scope.level ~= self.level
end

function Scope.__index:has_level_type(name)
  local base_scope = self
  repeat
    if self.symbol_table.has_type(name) then
      return true
    end
    base_scope = base_scope.parent
  until not base_scope or base_scope.level ~= self.level
end

function Scope.__index:add_value(symbol)
  self.symbol_table:add_value(symbol)
end

function Scope.__index:add_type(symbol)
  self.symbol_table:add_type(symbol)
end

function Scope.new(...)
  local self = setmetatable({}, Scope)
  Scope.constructor(self, ...)
  return self
end

return Scope