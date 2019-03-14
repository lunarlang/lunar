local Symbol = require("lunar.compiler.semantic.symbol")
local SymbolTable = require('lunar.compiler.semantic.symbol_table')
local SyntaxKind = require('lunar.ast.syntax_kind')
local SourceFileSymbol = setmetatable({}, {
  __index = Symbol,
})
SourceFileSymbol.__index = setmetatable({}, Symbol)
function SourceFileSymbol.new(...)
  return SourceFileSymbol.constructor(setmetatable({}, SourceFileSymbol), ...)
end
function SourceFileSymbol.constructor(self, ...)
  Symbol.constructor(self, ...)
  self.imports = {}
  self.globals = SymbolTable.new()
  self.exports = SymbolTable.new()
  self.return_declarations = {}
  self.export_as_declarations = {}
  return self
end
function SourceFileSymbol.__index:has_declared_returns()
  return (#self.return_declarations) > 0
end
function SourceFileSymbol.__index:has_declared_final_returns()
  for i = 1, (#self.return_declarations) do
    if self.return_declarations[i].syntax_kind == SyntaxKind.declare_returns_statement then
      return true
    end
  end
  return self:has_declared_export_as()
end
function SourceFileSymbol.__index:has_declared_export_as()
  return (#self.export_as_declarations) > 0
end
function SourceFileSymbol.__index:has_declared_export_values()
  return next(self.exports.values) ~= nil
end
function SourceFileSymbol.__index:bind_returns_declaration(stat)
  local decls = self.return_declarations
  decls[(#decls) + 1] = stat
end
function SourceFileSymbol.__index:bind_export_as_declaration(stat)
  local decls = self.export_as_declarations
  decls[(#decls) + 1] = stat
end
function SourceFileSymbol.__index:__tostring()
  return "SourceFileSymbol ('" .. tostring(self.name) .. "')"
end
return SourceFileSymbol
