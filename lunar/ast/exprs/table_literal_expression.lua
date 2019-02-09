local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local TableLiteralExpression = setmetatable({}, SyntaxNode)
TableLiteralExpression.__index = TableLiteralExpression

function TableLiteralExpression.new(fields)
  local super = SyntaxNode.new(SyntaxKind.table_literal_expression)
  local self = setmetatable(super, TableLiteralExpression)
  self.fields = fields

  return self
end

return TableLiteralExpression
