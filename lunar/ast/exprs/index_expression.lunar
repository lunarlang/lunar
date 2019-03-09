local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local IndexExpression = setmetatable({}, SyntaxNode)
IndexExpression.__index = IndexExpression

function IndexExpression.new(base, index)
  local super = SyntaxNode.new(SyntaxKind.index_expression)
  local self = setmetatable(super, IndexExpression)
  self.base = base
  self.index = index

  return self
end

return IndexExpression
