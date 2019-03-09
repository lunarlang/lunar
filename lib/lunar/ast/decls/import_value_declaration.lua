local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ImportValueDeclaration = setmetatable({}, SyntaxNode)
ImportValueDeclaration.__index = ImportValueDeclaration
function ImportValueDeclaration.new(identifier, is_type, alias_identifier)
  local super = SyntaxNode.new(SyntaxKind.import_value_declaration)
  local self = setmetatable(super, ImportValueDeclaration)
  self.identifier = identifier
  self.is_type = is_type
  self.alias_identifier = alias_identifier
  return self
end
return ImportValueDeclaration
