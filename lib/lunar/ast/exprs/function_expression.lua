local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local FunctionExpression = setmetatable({}, { __index = SyntaxNode })
FunctionExpression.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function FunctionExpression.new(parameters, block, return_type_annotation)
  return FunctionExpression.constructor(setmetatable({}, FunctionExpression), parameters, block, return_type_annotation)
end
function FunctionExpression.constructor(self, parameters, block, return_type_annotation)
  super(self, SyntaxKind.function_expression)
  self.parameters = parameters
  self.block = block
  self.return_type_annotation = return_type_annotation
  return self
end
return FunctionExpression
