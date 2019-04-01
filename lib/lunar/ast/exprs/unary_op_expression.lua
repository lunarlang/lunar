local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local UnaryOpExpression = setmetatable({}, {
  __index = SyntaxNode,
})
UnaryOpExpression.__index = setmetatable({}, SyntaxNode)
function UnaryOpExpression.new(start_pos, end_pos, operator, right_operand)
  return UnaryOpExpression.constructor(setmetatable({}, UnaryOpExpression), start_pos, end_pos, operator, right_operand)
end
function UnaryOpExpression.constructor(self, start_pos, end_pos, operator, right_operand)
  SyntaxNode.constructor(self, SyntaxKind.unary_op_expression, start_pos, end_pos)
  self.operator = operator
  self.right_operand = right_operand
  return self
end
return UnaryOpExpression
