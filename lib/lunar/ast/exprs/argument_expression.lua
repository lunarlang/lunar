local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ArgumentExpression = setmetatable({}, {
  __index = SyntaxNode,
})
ArgumentExpression.__index = setmetatable({}, SyntaxNode)
function ArgumentExpression.new(start_pos, end_pos, expr)
  return ArgumentExpression.constructor(setmetatable({}, ArgumentExpression), start_pos, end_pos, expr)
end
function ArgumentExpression.constructor(self, start_pos, end_pos, expr)
  SyntaxNode.constructor(self, SyntaxKind.argument_expression, start_pos, end_pos)
  self.value = expr
  return self
end
return ArgumentExpression
