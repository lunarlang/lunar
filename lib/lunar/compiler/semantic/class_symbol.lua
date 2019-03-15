local Symbol = require("lunar.compiler.semantic.symbol")
local SymbolTable = require('lunar.compiler.semantic.symbol_table')
local ClassSymbol = setmetatable({}, {
  __index = Symbol,
})
ClassSymbol.__index = setmetatable({}, Symbol)
function ClassSymbol.new(...)
  return ClassSymbol.constructor(setmetatable({}, ClassSymbol), ...)
end
function ClassSymbol.constructor(self, ...)
  Symbol.constructor(self, ...)
  self.members = SymbolTable.new()
  self.statics = SymbolTable.new()
  return self
end
function ClassSymbol.__index:merge_into(new_class_symbol)
  super.__index.merge_into(self, new_class_symbol)
  for _, k in pairs({
    "members",
    "statics",
  }) do
    local symtab = self[k]
    if symtab then
      local other_symtab = new_symbol[k]
      if other_symtab then
        for name, symbol in pairs(symtab.values) do
          local other_symbol = other_symtab:get_value(name)
          if other_symbol then
            symbol:merge_into(other_symbol)
          else
            other_symtab:add_value(symbol)
          end
        end
        for name, symbol in pairs(symtab.types) do
          local other_symbol = other_symtab:get_type(name)
          if other_symbol then
            symbol:merge_into(other_symbol)
          else
            other_symtab:add_type(symbol)
          end
        end
      else
        new_symbol[k] = symtab
      end
    end
  end
end
function ClassSymbol.__index:__tostring()
  return "ClassSymbol ('" .. tostring(self.name) .. "')"
end
return ClassSymbol
