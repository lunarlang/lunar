local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local BooleanLiteralExpression = setmetatable({}, SyntaxNode)
BooleanLiteralExpression.__index = BooleanLiteralExpression
function BooleanLiteralExpression.new(value)
  local super = SyntaxNode.new(SyntaxKind.boolean_literal_expression)
  local self = setmetatable(super, BooleanLiteralExpression)
  self.value = value
  return self
end
return BooleanLiteralExpression
