local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local BooleanLiteralExpression = setmetatable({}, { __index = SyntaxNode })
BooleanLiteralExpression.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function BooleanLiteralExpression.new(value)
  return BooleanLiteralExpression.constructor(setmetatable({}, BooleanLiteralExpression), value)
end
function BooleanLiteralExpression.constructor(self, value)
  super(self, SyntaxKind.boolean_literal_expression)
  self.value = value
  return self
end
return BooleanLiteralExpression
