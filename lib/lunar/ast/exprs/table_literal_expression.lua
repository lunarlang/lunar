local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local TableLiteralExpression = setmetatable({}, { __index = SyntaxNode })
TableLiteralExpression.__index = setmetatable({}, SyntaxNode)
local super = SyntaxNode.constructor
function TableLiteralExpression.new(fields)
  return TableLiteralExpression.constructor(setmetatable({}, TableLiteralExpression), fields)
end
function TableLiteralExpression.constructor(self, fields)
  super(self, SyntaxKind.table_literal_expression)
  self.fields = fields
  return self
end
return TableLiteralExpression
