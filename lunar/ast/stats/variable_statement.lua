local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local VariableStatement = setmetatable({}, SyntaxNode)
VariableStatement.__index = VariableStatement

function VariableStatement.new(namelist, exprlist)
  local super = SyntaxNode.new(SyntaxKind.variable_statement)
  local self = setmetatable(super, VariableStatement)
  self.namelist = namelist
  self.exprlist = exprlist

  return self
end

return VariableStatement
