local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ExportStatement = setmetatable({}, SyntaxNode)
ExportStatement.__index = ExportStatement
function ExportStatement.new(body)
  local super = SyntaxNode.new(SyntaxKind.export_statement)
  local self = setmetatable(super, ExportStatement)
  self.body = body
  return self
end
function ExportStatement.__index:lower()
  local identifier
  if self.body.syntax_kind == SyntaxKind.variable_statement then
    identifier = self.body.identlist[1]
  elseif self.body.syntax_kind == SyntaxKind.function_statement then
    identifier = self.body.base
  elseif self.body.syntax_kind == SyntaxKind.class_statement then
    identifier = self.body.identifier
  else
    error("Unimplemented export statement type '" .. self.body.syntax_kind .. "'")
  end
  return self.body, identifier
end
return ExportStatement
