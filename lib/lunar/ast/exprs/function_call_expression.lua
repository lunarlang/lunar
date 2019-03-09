local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local FunctionCallExpression = setmetatable({}, SyntaxNode)
FunctionCallExpression.__index = FunctionCallExpression
function FunctionCallExpression.new(base, arguments)
  local super = SyntaxNode.new(SyntaxKind.function_call_expression)
  local self = setmetatable(super, FunctionCallExpression)
  self.base = base
  self.arguments = arguments
  return self
end
return FunctionCallExpression
