local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local StringLiteralExpression = setmetatable({}, {
  __index = SyntaxNode,
})
StringLiteralExpression.__index = setmetatable({}, SyntaxNode)
function StringLiteralExpression.new(value)
  return StringLiteralExpression.constructor(setmetatable({}, StringLiteralExpression), value)
end
function StringLiteralExpression.constructor(self, value)
  SyntaxNode.constructor(self, SyntaxKind.string_literal_expression)
  self.value = value
  return self
end
return StringLiteralExpression
