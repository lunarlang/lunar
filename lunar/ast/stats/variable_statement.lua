local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local VariableStatement = setmetatable({}, SyntaxNode)
VariableStatement.__index = VariableStatement

function VariableStatement.new(namelist, type_annotations, exprlist)
  local super = SyntaxNode.new(SyntaxKind.variable_statement)
  local self = setmetatable(super, VariableStatement)
  self.namelist = namelist
  self.exprlist = exprlist
  self.type_annotations = type_annotations

  return self
end

return VariableStatement
