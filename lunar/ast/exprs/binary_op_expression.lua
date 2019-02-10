local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local BinaryOpExpression = setmetatable({}, SyntaxNode)
BinaryOpExpression.__index = BinaryOpExpression

function BinaryOpExpression.new(left_operand, operator, right_operand)
  local super = SyntaxNode.new(SyntaxKind.binary_op_expression)
  local self = setmetatable(super, BinaryOpExpression)
  self.left_operand = left_operand
  self.operator = operator
  self.right_operand = right_operand

  return self
end

return BinaryOpExpression
