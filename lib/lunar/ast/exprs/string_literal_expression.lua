local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local StringLiteralExpression = setmetatable({}, {
  __index = SyntaxNode,
})
StringLiteralExpression.__index = setmetatable({}, SyntaxNode)
function StringLiteralExpression.new(start_pos, end_pos, value)
  return StringLiteralExpression.constructor(setmetatable({}, StringLiteralExpression), start_pos, end_pos, value)
end
function StringLiteralExpression.constructor(self, start_pos, end_pos, value)
  SyntaxNode.constructor(self, SyntaxKind.string_literal_expression, start_pos, end_pos)
  self.value = value
  return self
end
return StringLiteralExpression
