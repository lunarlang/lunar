local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local VariableStatement = setmetatable({}, {
  __index = SyntaxNode,
})
VariableStatement.__index = setmetatable({}, SyntaxNode)
function VariableStatement.new(start_pos, end_pos, identlist, exprlist)
  return VariableStatement.constructor(setmetatable({}, VariableStatement), start_pos, end_pos, identlist, exprlist)
end
function VariableStatement.constructor(self, start_pos, end_pos, identlist, exprlist)
  SyntaxNode.constructor(self, SyntaxKind.variable_statement, start_pos, end_pos)
  self.identlist = identlist
  self.exprlist = exprlist
  return self
end
return VariableStatement
