local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local IndexFieldDeclaration = setmetatable({}, {
  __index = SyntaxNode,
})
IndexFieldDeclaration.__index = setmetatable({}, SyntaxNode)
function IndexFieldDeclaration.new(start_pos, end_pos, key, value)
  return IndexFieldDeclaration.constructor(setmetatable({}, IndexFieldDeclaration), start_pos, end_pos, key, value)
end
function IndexFieldDeclaration.constructor(self, start_pos, end_pos, key, value)
  SyntaxNode.constructor(self, SyntaxKind.index_field_declaration, start_pos, end_pos)
  self.key = key
  self.value = value
  return self
end
return IndexFieldDeclaration
