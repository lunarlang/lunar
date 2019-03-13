local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local NumberLiteralExpression = setmetatable({}, {
  __index = SyntaxNode,
})
NumberLiteralExpression.__index = setmetatable({}, SyntaxNode)
function NumberLiteralExpression.new(value)
  return NumberLiteralExpression.constructor(setmetatable({}, NumberLiteralExpression), value)
end
function NumberLiteralExpression.constructor(self, value)
  SyntaxNode.constructor(self, SyntaxKind.number_literal_expression)
  self.value = value
  return self
end
return NumberLiteralExpression
