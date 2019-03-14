local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local ExpressionStatement = setmetatable({}, { __index = SyntaxNode })
ExpressionStatement.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function ExpressionStatement.new(expr)
  return ExpressionStatement.constructor(setmetatable({}, ExpressionStatement), expr)
end
function ExpressionStatement.constructor(self, expr)
  super(self, SyntaxKind.expression_statement)
  self.expr = expr
  return self
end
return ExpressionStatement
