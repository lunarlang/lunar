local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local MemberFieldDeclaration = setmetatable({}, { __index = SyntaxNode })
MemberFieldDeclaration.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function MemberFieldDeclaration.new(member_identifier, value)
  return MemberFieldDeclaration.constructor(setmetatable({}, MemberFieldDeclaration), member_identifier, value)
end
function MemberFieldDeclaration.constructor(self, member_identifier, value)
  super(self, SyntaxKind.member_field_declaration)
  self.member_identifier = member_identifier
  self.value = value
  return self
end
return MemberFieldDeclaration
