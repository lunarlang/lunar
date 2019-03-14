local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local VariableStatement = setmetatable({}, { __index = SyntaxNode })
VariableStatement.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function VariableStatement.new(identlist, exprlist)
  return VariableStatement.constructor(setmetatable({}, VariableStatement), identlist, exprlist)
end
function VariableStatement.constructor(self, identlist, exprlist)
  super(self, SyntaxKind.variable_statement)
  self.identlist = identlist
  self.exprlist = exprlist
  return self
end
return VariableStatement
