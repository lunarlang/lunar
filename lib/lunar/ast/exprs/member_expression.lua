local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local MemberExpression = setmetatable({}, SyntaxNode)
MemberExpression.__index = MemberExpression
function MemberExpression.new(base, member_identifier, has_colon)
  if has_colon == nil then
    has_colon = false
  end
  local super = SyntaxNode.new(SyntaxKind.member_expression)
  local self = setmetatable(super, MemberExpression)
  self.base = base
  self.member_identifier = member_identifier
  self.has_colon = has_colon
  return self
end
return MemberExpression
