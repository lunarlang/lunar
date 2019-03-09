local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ArgumentExpression = setmetatable({}, SyntaxNode)
ArgumentExpression.__index = ArgumentExpression
function ArgumentExpression.new(expr)
  local super = SyntaxNode.new(SyntaxKind.argument_expression)
  local self = setmetatable(super, ArgumentExpression)
  self.value = expr
  return self
end
return ArgumentExpression
