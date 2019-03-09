local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local TypeAssertionExpression = setmetatable({}, {
  __index = SyntaxNode,
})
TypeAssertionExpression.__index = setmetatable({}, SyntaxNode)
function TypeAssertionExpression.new(base, type)
  return TypeAssertionExpression.constructor(setmetatable({}, TypeAssertionExpression), base, type)
end
function TypeAssertionExpression.constructor(self, base, type)
  SyntaxNode.constructor(self, SyntaxKind.type_assertion_expression)
  self.base = base
  self.type = type
  return self
end
return TypeAssertionExpression
