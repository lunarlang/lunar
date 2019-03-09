local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local VariableArgumentExpression = setmetatable({}, SyntaxNode)
VariableArgumentExpression.__index = VariableArgumentExpression
function VariableArgumentExpression.new()
  local super = SyntaxNode.new(SyntaxKind.variable_argument_expression)
  local self = setmetatable(super, VariableArgumentExpression)
  self.symbol = nil
  return self
end
return VariableArgumentExpression