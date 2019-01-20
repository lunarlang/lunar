local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local FalseLiteralExpression = setmetatable({}, SyntaxNode)
FalseLiteralExpression.__index = FalseLiteralExpression

function FalseLiteralExpression.new()
  local super = SyntaxNode.new(SyntaxKind.false_literal_expression)
  local self = setmetatable(super, FalseLiteralExpression)

  return self
end

return FalseLiteralExpression
