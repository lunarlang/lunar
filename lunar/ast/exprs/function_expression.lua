local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local FunctionExpression = setmetatable({}, SyntaxNode)
FunctionExpression.__index = FunctionExpression

function FunctionExpression.new(parameters, block)
  local super = SyntaxNode.new(SyntaxKind.function_expression)
  local self = setmetatable(super, FunctionExpression)
  self.parameters = parameters
  self.block = block

  return self
end

return FunctionExpression
