local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local MemberExpression = setmetatable({}, SyntaxNode)
MemberExpression.__index = MemberExpression

function MemberExpression.new(left, right, has_colon)
  if has_colon == nil then has_colon = false end

  local super = SyntaxNode.new(SyntaxKind.member_expression)
  local self = setmetatable(super, MemberExpression)
  self.left_member = left
  self.right_member = right
  self.has_colon = has_colon

  return self
end

return MemberExpression
