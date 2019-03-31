local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local BooleanLiteralExpression = setmetatable({}, {
  __index = SyntaxNode,
})
BooleanLiteralExpression.__index = setmetatable({}, SyntaxNode)
function BooleanLiteralExpression.new(start_pos, end_pos, value)
  return BooleanLiteralExpression.constructor(setmetatable({}, BooleanLiteralExpression), start_pos, end_pos, value)
end
function BooleanLiteralExpression.constructor(self, start_pos, end_pos, value)
  SyntaxNode.constructor(self, SyntaxKind.boolean_literal_expression, start_pos, end_pos)
  self.value = value
  return self
end
return BooleanLiteralExpression
