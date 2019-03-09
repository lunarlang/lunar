local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local ImportValueDeclaration = setmetatable({}, SyntaxNode)
ImportValueDeclaration.__index = ImportValueDeclaration

function ImportValueDeclaration.new(identifier, is_type, alias_identifier)
  local super = SyntaxNode.new(SyntaxKind.import_value_declaration)
  local self = setmetatable(super, ImportValueDeclaration)
  self.identifier = identifier -- Identifier
  self.is_type = is_type -- boolean or nil
  self.alias_identifier = alias_identifier -- Identifier or nil

  return self
end

return ImportValueDeclaration
