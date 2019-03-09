local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local MemberFieldDeclaration = setmetatable({}, SyntaxNode)
MemberFieldDeclaration.__index = MemberFieldDeclaration
function MemberFieldDeclaration.new(member_identifier, value)
  local super = SyntaxNode.new(SyntaxKind.member_field_declaration)
  local self = setmetatable(super, MemberFieldDeclaration)
  self.member_identifier = member_identifier
  self.value = value
  return self
end
return MemberFieldDeclaration
