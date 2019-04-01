local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local NumberLiteralExpression = setmetatable({}, {
  __index = SyntaxNode,
})
NumberLiteralExpression.__index = setmetatable({}, SyntaxNode)
function NumberLiteralExpression.new(start_pos, end_pos, value)
  return NumberLiteralExpression.constructor(setmetatable({}, NumberLiteralExpression), start_pos, end_pos, value)
end
function NumberLiteralExpression.constructor(self, start_pos, end_pos, value)
  SyntaxNode.constructor(self, SyntaxKind.number_literal_expression, start_pos, end_pos)
  self.value = value
  return self
end
return NumberLiteralExpression
