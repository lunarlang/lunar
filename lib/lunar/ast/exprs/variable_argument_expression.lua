local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local VariableArgumentExpression = setmetatable({}, { __index = SyntaxNode })
VariableArgumentExpression.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function VariableArgumentExpression.new()
  return VariableArgumentExpression.constructor(setmetatable({}, VariableArgumentExpression))
end
function VariableArgumentExpression.constructor(self)
  super(self, SyntaxKind.variable_argument_expression)
  self.symbol = nil
  return self
end
return VariableArgumentExpression
