local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local VariableArgumentExpression = setmetatable({}, {
  __index = SyntaxNode,
})
VariableArgumentExpression.__index = setmetatable({}, SyntaxNode)
function VariableArgumentExpression.new(start_pos, end_pos)
  return VariableArgumentExpression.constructor(setmetatable({}, VariableArgumentExpression), start_pos, end_pos)
end
function VariableArgumentExpression.constructor(self, start_pos, end_pos)
  SyntaxNode.constructor(self, SyntaxKind.variable_argument_expression, start_pos, end_pos)
  return self
end
return VariableArgumentExpression
