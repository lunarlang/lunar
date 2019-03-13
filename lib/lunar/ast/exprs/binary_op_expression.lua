local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local BinaryOpExpression = setmetatable({}, {
  __index = SyntaxNode,
})
BinaryOpExpression.__index = setmetatable({}, SyntaxNode)
function BinaryOpExpression.new(left_operand, operator, right_operand)
  return BinaryOpExpression.constructor(setmetatable({}, BinaryOpExpression), left_operand, operator, right_operand)
end
function BinaryOpExpression.constructor(self, left_operand, operator, right_operand)
  SyntaxNode.constructor(self, SyntaxKind.binary_op_expression)
  self.left_operand = left_operand
  self.operator = operator
  self.right_operand = right_operand
  return self
end
return BinaryOpExpression
