local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local NilLiteralExpression = setmetatable({}, {
  __index = SyntaxNode,
})
NilLiteralExpression.__index = setmetatable({}, SyntaxNode)
function NilLiteralExpression.new(start_pos, end_pos)
  return NilLiteralExpression.constructor(setmetatable({}, NilLiteralExpression), start_pos, end_pos)
end
function NilLiteralExpression.constructor(self, start_pos, end_pos)
  SyntaxNode.constructor(self, SyntaxKind.nil_literal_expression, start_pos, end_pos)
  return self
end
return NilLiteralExpression
