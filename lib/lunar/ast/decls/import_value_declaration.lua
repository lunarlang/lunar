local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ImportValueDeclaration = setmetatable({}, {
  __index = SyntaxNode,
})
ImportValueDeclaration.__index = setmetatable({}, SyntaxNode)
function ImportValueDeclaration.new(identifier, is_type, alias_identifier)
  return ImportValueDeclaration.constructor(setmetatable({}, ImportValueDeclaration), identifier, is_type, alias_identifier)
end
function ImportValueDeclaration.constructor(self, identifier, is_type, alias_identifier)
  SyntaxNode.constructor(self, SyntaxKind.import_value_declaration)
  self.identifier = identifier
  self.is_type = is_type
  self.alias_identifier = alias_identifier
  return self
end
return ImportValueDeclaration
