local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local PrefixExpression = setmetatable({}, SyntaxNode)
PrefixExpression.__index = PrefixExpression
function PrefixExpression.new(expr)
  local super = SyntaxNode.new(SyntaxKind.prefix_expression)
  local self = setmetatable(super, PrefixExpression)
  self.expr = expr
  return self
end
return PrefixExpression
