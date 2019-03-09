local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local FunctionCallExpression = setmetatable({}, {
  __index = SyntaxNode,
})
FunctionCallExpression.__index = setmetatable({}, SyntaxNode)
function FunctionCallExpression.new(base, arguments)
  return FunctionCallExpression.constructor(setmetatable({}, FunctionCallExpression), base, arguments)
end
function FunctionCallExpression.constructor(self, base, arguments)
  SyntaxNode.constructor(self, SyntaxKind.function_call_expression)
  self.base = base
  self.arguments = arguments
  return self
end
return FunctionCallExpression
