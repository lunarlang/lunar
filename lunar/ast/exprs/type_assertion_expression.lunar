local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local TypeAssertionExpression = setmetatable({}, SyntaxNode)
TypeAssertionExpression.__index = TypeAssertionExpression

function TypeAssertionExpression.new(base, type)
  local super = SyntaxNode.new(SyntaxKind.type_assertion_expression)
  local self = setmetatable(super, TypeAssertionExpression)
  self.base = base
  self.type = type

  return self
end

return TypeAssertionExpression
