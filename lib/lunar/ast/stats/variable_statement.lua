local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local VariableStatement = setmetatable({}, SyntaxNode)
VariableStatement.__index = VariableStatement
function VariableStatement.new(identlist, exprlist)
  local super = SyntaxNode.new(SyntaxKind.variable_statement)
  local self = setmetatable(super, VariableStatement)
  self.identlist = identlist
  self.exprlist = exprlist
  return self
end
return VariableStatement
