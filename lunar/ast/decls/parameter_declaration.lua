local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local ParameterDeclaration = setmetatable({}, SyntaxNode)
ParameterDeclaration.__index = ParameterDeclaration

function ParameterDeclaration.new(name, type_annotation)
  local super = SyntaxNode.new(SyntaxKind.parameter_declaration)
  local self = setmetatable(super, ParameterDeclaration)
  self.name = name
  self.type_annotation = type_annotation

  return self
end

return ParameterDeclaration
