local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local VariableArgumentExpression = setmetatable({}, {
  __index = SyntaxNode,
})
VariableArgumentExpression.__index = setmetatable({}, SyntaxNode)
function VariableArgumentExpression.new()
  return VariableArgumentExpression.constructor(setmetatable({}, VariableArgumentExpression))
end
function VariableArgumentExpression.constructor(self)
  SyntaxNode.constructor(self, SyntaxKind.variable_argument_expression)
  return self
end
return VariableArgumentExpression
