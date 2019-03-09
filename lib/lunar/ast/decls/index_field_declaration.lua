local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local IndexFieldDeclaration = setmetatable({}, SyntaxNode)
IndexFieldDeclaration.__index = IndexFieldDeclaration
function IndexFieldDeclaration.new(key, value)
  local super = SyntaxNode.new(SyntaxKind.index_field_declaration)
  local self = setmetatable(super, IndexFieldDeclaration)
  self.key = key
  self.value = value
  return self
end
return IndexFieldDeclaration
