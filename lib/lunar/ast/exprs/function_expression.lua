local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local FunctionExpression = setmetatable({}, {
  __index = SyntaxNode,
})
FunctionExpression.__index = setmetatable({}, SyntaxNode)
function FunctionExpression.new(start_pos, end_pos, parameters, block, return_type_annotation)
  return FunctionExpression.constructor(setmetatable({}, FunctionExpression), start_pos, end_pos, parameters, block, return_type_annotation)
end
function FunctionExpression.constructor(self, start_pos, end_pos, parameters, block, return_type_annotation)
  SyntaxNode.constructor(self, SyntaxKind.function_expression, start_pos, end_pos)
  self.parameters = parameters
  self.block = block
  self.return_type_annotation = return_type_annotation
  return self
end
return FunctionExpression
