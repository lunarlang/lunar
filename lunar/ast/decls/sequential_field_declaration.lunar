local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local SequentialFieldDeclaration = setmetatable({}, SyntaxNode)
SequentialFieldDeclaration.__index = SequentialFieldDeclaration

function SequentialFieldDeclaration.new(value)
  local super = SyntaxNode.new(SyntaxKind.sequential_field_declaration)
  local self = setmetatable(super, SequentialFieldDeclaration)
  self.value = value

  return self
end

return SequentialFieldDeclaration
