local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local TrueLiteralExpression = setmetatable({}, SyntaxNode)
TrueLiteralExpression.__index = TrueLiteralExpression

function TrueLiteralExpression.new()
  local super = SyntaxNode.new(SyntaxKind.true_literal_expression)
  local self = setmetatable(super, TrueLiteralExpression)

  return self
end

return TrueLiteralExpression
