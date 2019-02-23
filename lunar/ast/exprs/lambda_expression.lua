local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local ReturnStatement = require "lunar.ast.stats.return_statement"
local FunctionExpression = require "lunar.ast.exprs.function_expression"

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

function LambdaExpression:lower()
  local block

  if self.implicit_return then
    -- rewrites the body to a return statement
    block = { ReturnStatement.new({ self.body }) }
  else
    -- compatible type, so we simply reuse it
    block = self.body
  end

  return FunctionExpression.new(self.parameters, block)
end

return LambdaExpression
