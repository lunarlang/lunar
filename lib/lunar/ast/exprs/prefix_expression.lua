local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local PrefixExpression = setmetatable({}, { __index = SyntaxNode })
PrefixExpression.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function PrefixExpression.new(expr)
  return PrefixExpression.constructor(setmetatable({}, PrefixExpression), expr)
end
function PrefixExpression.constructor(self, expr)
  super(self, SyntaxKind.prefix_expression)
  self.expr = expr
  return self
end
return PrefixExpression
