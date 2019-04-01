local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local PrefixExpression = setmetatable({}, {
  __index = SyntaxNode,
})
PrefixExpression.__index = setmetatable({}, SyntaxNode)
function PrefixExpression.new(start_pos, end_pos, expr)
  return PrefixExpression.constructor(setmetatable({}, PrefixExpression), start_pos, end_pos, expr)
end
function PrefixExpression.constructor(self, start_pos, end_pos, expr)
  SyntaxNode.constructor(self, SyntaxKind.prefix_expression, start_pos, end_pos)
  self.expr = expr
  return self
end
return PrefixExpression
