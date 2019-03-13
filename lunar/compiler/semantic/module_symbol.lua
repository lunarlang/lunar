local Symbol = require "lunar.compiler.semantic.symbol"
local SymbolTable = require 'lunar.compiler.semantic.symbol_table'

local ModuleSymbol = setmetatable({}, Symbol)
ModuleSymbol.__index = setmetatable({}, Symbol)

function ModuleSymbol.new(...)
  local self = setmetatable({}, ModuleSymbol)
  ModuleSymbol.constructor(self, ...)
  return self
end

function ModuleSymbol.constructor(self, path)
  Symbol.constructor(self, path)

  self.imports = {} -- ImportLink[]
  self.globals = SymbolTable.new()
  self.return_declarations = {} -- Node[]
end

return ModuleSymbol