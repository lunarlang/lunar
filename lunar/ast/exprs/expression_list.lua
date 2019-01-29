local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"

local ExpressionList = setmetatable({}, SyntaxNode)
ExpressionList.__index = ExpressionList

function ExpressionList.new(...)
  local super = SyntaxNode.new(SyntaxKind.expression_list)
  local self = setmetatable(super, ExpressionList)
  self.expressions = { ... }

  return self
end

return ExpressionList
