local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local UnaryOpExpression = setmetatable({}, { __index = SyntaxNode })
UnaryOpExpression.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function UnaryOpExpression.new(operator, right_operand)
  return UnaryOpExpression.constructor(setmetatable({}, UnaryOpExpression), operator, right_operand)
end
function UnaryOpExpression.constructor(self, operator, right_operand)
  super(self, SyntaxKind.unary_op_expression)
  self.operator = operator
  self.right_operand = right_operand
  return self
end
return UnaryOpExpression
