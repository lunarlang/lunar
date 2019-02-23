local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local LambdaExpression = setmetatable({}, SyntaxNode)
LambdaExpression.__index = LambdaExpression

function LambdaExpression.new(parameters, body, implicit_return)
  local super = SyntaxNode.new(SyntaxKind.lambda_expression)
  local self = setmetatable(super, LambdaExpression)
  self.parameters = parameters
  self.body = body -- could be a block or a single expression
  self.implicit_return = implicit_return -- if single expression, it is implicitly returned

  return self
end

return LambdaExpression
