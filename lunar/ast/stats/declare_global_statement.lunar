local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local DeclareGlobalStatement = setmetatable({}, SyntaxNode)
DeclareGlobalStatement.__index = DeclareGlobalStatement

function DeclareGlobalStatement.new(identifier, is_type_declaration)
  local super = SyntaxNode.new(SyntaxKind.declare_global_statement)
  local self = setmetatable(super, DeclareGlobalStatement)
  self.identifier = identifier
  self.is_type_declaration = is_type_declaration

  return self
end

return DeclareGlobalStatement
