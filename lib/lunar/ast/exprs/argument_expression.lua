local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ArgumentExpression = setmetatable({}, {
  __index = SyntaxNode,
})
ArgumentExpression.__index = setmetatable({}, SyntaxNode)
function ArgumentExpression.new(expr)
  return ArgumentExpression.constructor(setmetatable({}, ArgumentExpression), expr)
end
function ArgumentExpression.constructor(self, expr)
  SyntaxNode.constructor(self, SyntaxKind.argument_expression)
  self.value = expr
  return self
end
return ArgumentExpression
