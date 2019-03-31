local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ExpressionStatement = setmetatable({}, {
  __index = SyntaxNode,
})
ExpressionStatement.__index = setmetatable({}, SyntaxNode)
function ExpressionStatement.new(start_pos, end_pos, expr)
  return ExpressionStatement.constructor(setmetatable({}, ExpressionStatement), start_pos, end_pos, expr)
end
function ExpressionStatement.constructor(self, start_pos, end_pos, expr)
  SyntaxNode.constructor(self, SyntaxKind.expression_statement, start_pos, end_pos)
  self.expr = expr
  return self
end
return ExpressionStatement
