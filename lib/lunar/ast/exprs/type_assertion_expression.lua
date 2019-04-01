local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local TypeAssertionExpression = setmetatable({}, {
  __index = SyntaxNode,
})
TypeAssertionExpression.__index = setmetatable({}, SyntaxNode)
function TypeAssertionExpression.new(start_pos, end_pos, base, type)
  return TypeAssertionExpression.constructor(setmetatable({}, TypeAssertionExpression), start_pos, end_pos, base, type)
end
function TypeAssertionExpression.constructor(self, start_pos, end_pos, base, type)
  SyntaxNode.constructor(self, SyntaxKind.type_assertion_expression, start_pos, end_pos)
  self.base = base
  self.type = type
  return self
end
return TypeAssertionExpression
