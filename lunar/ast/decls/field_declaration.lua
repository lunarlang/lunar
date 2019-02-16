local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local FieldDeclaration = setmetatable({}, SyntaxNode)
FieldDeclaration.__index = FieldDeclaration

function FieldDeclaration.new(key, value)
  local super = SyntaxNode.new(SyntaxKind.field_declaration)
  local self = setmetatable(super, FieldDeclaration)
  self.key = key
  self.value = value

  return self
end

return FieldDeclaration
