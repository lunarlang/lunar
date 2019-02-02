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

function TableLiteralExpression.try_parse(parser)
  if parser:match(TokenType.left_brace) then
    local fields = parser:parse_field_list()
    parser:expect(TokenType.right_brace, "Expected '}' to close '{'")

    return TableLiteralExpression.new(fields)
  end
end

return TableLiteralExpression
