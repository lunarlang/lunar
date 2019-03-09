local SymbolTable = require("lunar.compiler.semantic.symbol_table")
local Scope = {}
Scope.__index = {}
function Scope.constructor(self, level, parent, env, file_path)
  self.level = level
  self.parent = parent
  if (not parent) then
    self.env = env
    self.file_path = file_path
  end
  self.symbol_table = SymbolTable.new()
end
function Scope.__index:get_value(name)
  if self.parent then
    return self.symbol_table:get_value(name) or self.parent:get_value(name)
  else
    return self.symbol_table:get_value(name) or self.env:get_global_value(self.file_path, name)
  end
end
function Scope.__index:get_type(name)
  if self.parent then
    return self.symbol_table:get_type(name) or self.parent:get_type(name)
  else
    return self.symbol_table:get_type(name) or self.env:get_global_type(self.file_path, name)
  end
end
function Scope.__index:has_value(name)
  if self.parent then
    return self.symbol_table:has_value(name) or self.parent:has_value(name)
  else
    return self.symbol_table:has_value(name) or self.env:has_global_value(self.file_path, name)
  end
end
function Scope.__index:has_type(name)
  if self.parent then
    return self.symbol_table:has_type(name) or self.parent:has_type(name)
  else
    return self.symbol_table:has_type(name) or self.env:has_global_type(self.file_path, name)
  end
end
function Scope.__index:has_level_value(name)
  local base_scope = self
  repeat
    if self.symbol_table:has_value(name) then
      return true
    end
    base_scope = base_scope.parent
  until (not base_scope) or base_scope.level ~= self.level
end
function Scope.__index:has_level_type(name)
  local base_scope = self
  repeat
    if self.symbol_table.has_type(name) then
      return true
    end
    base_scope = base_scope.parent
  until (not base_scope) or base_scope.level ~= self.level
end
function Scope.__index:add_value(symbol)
  self.symbol_table:add_value(symbol)
end
function Scope.__index:add_type(symbol)
  if self.parent then
    error("Types must be bound to a root scope")
  end
  self.symbol_table:add_type(symbol)
end
function Scope.new(...)
  local self = setmetatable({}, Scope)
  Scope.constructor(self, ...)
  return self
end
return Scope
