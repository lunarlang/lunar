local SymbolTable = {}
SymbolTable.__index = {}
function SymbolTable.new()
  return SymbolTable.constructor(setmetatable({}, SymbolTable))
end
function SymbolTable.constructor(self)
  self.values = {}
  self.types = {}
  return self
end
function SymbolTable.__index:get_value(name)
  return self.values[name]
end
function SymbolTable.__index:get_type(name)
  return self.types[name]
end
function SymbolTable.__index:has_value(name)
  return self.values[name] ~= nil
end
function SymbolTable.__index:has_type(name)
  return self.types[name] ~= nil
end
function SymbolTable.__index:add_value(symbol)
  if self.values[symbol.name] then
    error("Duplicate value symbol '" .. symbol.name .. "' was declared in the same scope")
  else
    self.values[symbol.name] = symbol
  end
end
function SymbolTable.__index:add_type(symbol)
  if self.types[symbol.name] then
    error("Duplicate type symbol '" .. symbol.name .. "' was declared in the same scope")
  else
    self.types[symbol.name] = symbol
  end
end
function SymbolTable.__index:merge_declarations(other)
  for global_name, other_symbol in pairs(other.values) do
    local our_symbol = self.values[global_name]
    if our_symbol then
      if other_symbol ~= our_symbol then
        error("Attempt to merge declarations for duplicate value symbol '" .. global_name .. "'")
      end
    else
      self.values[global_name] = other_symbol
    end
  end
  for global_name, other_symbol in pairs(other.types) do
    local our_symbol = self.types[global_name]
    if our_symbol then
      if other_symbol ~= our_symbol then
        error("Attempt to merge declarations for duplicate type symbol '" .. global_name .. "'")
      end
    else
      self.types[global_name] = other_symbol
    end
  end
end
return SymbolTable
