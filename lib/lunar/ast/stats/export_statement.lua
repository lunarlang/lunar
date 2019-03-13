local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ExportStatement = setmetatable({}, {
  __index = SyntaxNode,
})
ExportStatement.__index = setmetatable({}, SyntaxNode)
function ExportStatement.new(body)
  return ExportStatement.constructor(setmetatable({}, ExportStatement), body)
end
function ExportStatement.constructor(self, body)
  SyntaxNode.constructor(self, SyntaxKind.export_statement)
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
