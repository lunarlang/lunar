local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local IndexExpression = setmetatable({}, {
  __index = SyntaxNode,
})
IndexExpression.__index = setmetatable({}, SyntaxNode)
function IndexExpression.new(start_pos, end_pos, base, index)
  return IndexExpression.constructor(setmetatable({}, IndexExpression), start_pos, end_pos, base, index)
end
function IndexExpression.constructor(self, start_pos, end_pos, base, index)
  SyntaxNode.constructor(self, SyntaxKind.index_expression, start_pos, end_pos)
  self.base = base
  self.index = index
  return self
end
return IndexExpression
