local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local DeclarationStatement = setmetatable({}, SyntaxNode)
DeclarationStatement.__index = DeclarationStatement

function DeclarationStatement.new(context, identifier, is_type_declaration)
  local super = SyntaxNode.new(SyntaxKind.declaration_statement)
  local self = setmetatable(super, DeclarationStatement)
  self.context = context
  self.identifier = identifier
  self.is_type_declaration = is_type_declaration

  return self
end

return DeclarationStatement
