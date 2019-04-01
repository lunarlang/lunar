local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local MemberExpression = setmetatable({}, {
  __index = SyntaxNode,
})
MemberExpression.__index = setmetatable({}, SyntaxNode)
function MemberExpression.new(start_pos, end_pos, base, member_identifier, has_colon)
  return MemberExpression.constructor(setmetatable({}, MemberExpression), start_pos, end_pos, base, member_identifier, has_colon)
end
function MemberExpression.constructor(self, start_pos, end_pos, base, member_identifier, has_colon)
  SyntaxNode.constructor(self, SyntaxKind.member_expression, start_pos, end_pos)
  if has_colon == nil then
    has_colon = false
  end
  self.base = base
  self.member_identifier = member_identifier
  self.has_colon = has_colon
  return self
end
return MemberExpression
