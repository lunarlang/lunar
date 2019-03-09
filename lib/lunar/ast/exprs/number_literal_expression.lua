local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local NumberLiteralExpression = setmetatable({}, SyntaxNode)
NumberLiteralExpression.__index = NumberLiteralExpression
function NumberLiteralExpression.new(value)
  local super = SyntaxNode.new(SyntaxKind.number_literal_expression)
  local self = setmetatable(super, NumberLiteralExpression)
  self.value = value
  return self
end
return NumberLiteralExpression
