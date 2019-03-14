local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local MemberExpression = setmetatable({}, { __index = SyntaxNode })
MemberExpression.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function MemberExpression.new(base, member_identifier, has_colon)
  return MemberExpression.constructor(setmetatable({}, MemberExpression), base, member_identifier, has_colon)
end
function MemberExpression.constructor(self, base, member_identifier, has_colon)
  super(self, SyntaxKind.member_expression)
  if has_colon == nil then
    has_colon = false
  end
  self.base = base
  self.member_identifier = member_identifier
  self.has_colon = has_colon
  return self
end
return MemberExpression
