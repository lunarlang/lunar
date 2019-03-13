local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ExpressionStatement = setmetatable({}, {
  __index = SyntaxNode,
})
ExpressionStatement.__index = setmetatable({}, SyntaxNode)
function ExpressionStatement.new(expr)
  return ExpressionStatement.constructor(setmetatable({}, ExpressionStatement), expr)
end
function ExpressionStatement.constructor(self, expr)
  SyntaxNode.constructor(self, SyntaxKind.expression_statement)
  self.expr = expr
  return self
end
return ExpressionStatement
