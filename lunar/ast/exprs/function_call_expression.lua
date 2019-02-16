local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local FunctionCallExpression = setmetatable({}, SyntaxNode)
FunctionCallExpression.__index = FunctionCallExpression

function FunctionCallExpression.new(member_expression, arguments)
  local super = SyntaxNode.new(SyntaxKind.function_call_expression)
  local self = setmetatable(super, FunctionCallExpression)
  self.member_expression = member_expression
  self.arguments = arguments

  return self
end

return FunctionCallExpression
