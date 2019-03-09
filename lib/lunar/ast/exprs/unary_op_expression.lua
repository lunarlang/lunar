local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local UnaryOpExpression = setmetatable({}, SyntaxNode)
UnaryOpExpression.__index = UnaryOpExpression

function UnaryOpExpression.new(operator, right_operand)
  local super = SyntaxNode.new(SyntaxKind.unary_op_expression)
  local self = setmetatable(super, UnaryOpExpression)
  self.operator = operator
  self.right_operand = right_operand

  return self
end

return UnaryOpExpression
