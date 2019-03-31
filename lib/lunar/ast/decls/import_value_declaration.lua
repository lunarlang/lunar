local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ImportValueDeclaration = setmetatable({}, {
  __index = SyntaxNode,
})
ImportValueDeclaration.__index = setmetatable({}, SyntaxNode)
function ImportValueDeclaration.new(start_pos, end_pos, identifier, is_type, alias_identifier)
  return ImportValueDeclaration.constructor(setmetatable({}, ImportValueDeclaration), start_pos, end_pos, identifier, is_type, alias_identifier)
end
function ImportValueDeclaration.constructor(self, start_pos, end_pos, identifier, is_type, alias_identifier)
  SyntaxNode.constructor(self, SyntaxKind.import_value_declaration, start_pos, end_pos)
  self.identifier = identifier
  self.is_type = is_type
  self.alias_identifier = alias_identifier
  return self
end
return ImportValueDeclaration
