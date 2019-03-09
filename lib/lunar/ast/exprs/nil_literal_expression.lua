local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local NilLiteralExpression = setmetatable({}, SyntaxNode)
NilLiteralExpression.__index = NilLiteralExpression
function NilLiteralExpression.new()
  local super = SyntaxNode.new(SyntaxKind.nil_literal_expression)
  local self = setmetatable(super, NilLiteralExpression)
  return self
end
return NilLiteralExpression
