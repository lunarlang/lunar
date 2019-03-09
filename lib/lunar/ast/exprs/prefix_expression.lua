local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local PrefixExpression = setmetatable({}, {
  __index = SyntaxNode,
})
PrefixExpression.__index = setmetatable({}, SyntaxNode)
function PrefixExpression.new(expr)
  return PrefixExpression.constructor(setmetatable({}, PrefixExpression), expr)
end
function PrefixExpression.constructor(self, expr)
  SyntaxNode.constructor(self, SyntaxKind.prefix_expression)
  self.expr = expr
  return self
end
return PrefixExpression
