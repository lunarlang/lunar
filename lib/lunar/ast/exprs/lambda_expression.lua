local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ReturnStatement = require("lunar.ast.stats.return_statement")
local FunctionExpression = require("lunar.ast.exprs.function_expression")
local LambdaExpression = setmetatable({}, {
  __index = SyntaxNode,
})
LambdaExpression.__index = setmetatable({}, SyntaxNode)
function LambdaExpression.new(parameters, body, implicit_return, return_type_annotation)
  return LambdaExpression.constructor(setmetatable({}, LambdaExpression), parameters, body, implicit_return, return_type_annotation)
end
function LambdaExpression.constructor(self, parameters, body, implicit_return, return_type_annotation)
  SyntaxNode.constructor(self, SyntaxKind.lambda_expression)
  self.parameters = parameters
  self.body = body
  self.implicit_return = implicit_return
  self.return_type_annotation = return_type_annotation
  return self
end
function LambdaExpression.__index:lower()
  local block
  if self.implicit_return then
    block = {
      ReturnStatement.new({
        self.body,
      }),
    }
  else
    block = self.body
  end
  return FunctionExpression.new(self.parameters, block)
end
return LambdaExpression
