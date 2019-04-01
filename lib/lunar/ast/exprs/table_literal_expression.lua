local SyntaxKind = require("lunar.ast.syntax_kind")
local SyntaxNode = require("lunar.ast.syntax_node")
local TableLiteralExpression = setmetatable({}, {
  __index = SyntaxNode,
})
TableLiteralExpression.__index = setmetatable({}, SyntaxNode)
function TableLiteralExpression.new(start_pos, end_pos, fields)
  return TableLiteralExpression.constructor(setmetatable({}, TableLiteralExpression), start_pos, end_pos, fields)
end
function TableLiteralExpression.constructor(self, start_pos, end_pos, fields)
  SyntaxNode.constructor(self, SyntaxKind.table_literal_expression, start_pos, end_pos)
  self.fields = fields
  return self
end
return TableLiteralExpression
