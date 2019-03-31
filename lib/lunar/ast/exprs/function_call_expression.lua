local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local FunctionCallExpression = setmetatable({}, {
  __index = SyntaxNode,
})
FunctionCallExpression.__index = setmetatable({}, SyntaxNode)
function FunctionCallExpression.new(start_pos, end_pos, base, arguments)
  return FunctionCallExpression.constructor(setmetatable({}, FunctionCallExpression), start_pos, end_pos, base, arguments)
end
function FunctionCallExpression.constructor(self, start_pos, end_pos, base, arguments)
  SyntaxNode.constructor(self, SyntaxKind.function_call_expression, start_pos, end_pos)
  self.base = base
  self.arguments = arguments
  return self
end
return FunctionCallExpression
