local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local BooleanLiteralExpression = setmetatable({}, SyntaxNode)
BooleanLiteralExpression.__index = BooleanLiteralExpression

function BooleanLiteralExpression.new(value)
  local super = SyntaxNode.new(SyntaxKind.boolean_literal_expression)
  local self = setmetatable(super, BooleanLiteralExpression)
  self.value = value

  return self
end

function BooleanLiteralExpression.try_parse(parser)
  if parser:assert(TokenType.true_keyword, TokenType.false_keyword) then
    local token = parser:consume()

    return BooleanLiteralExpression.new(token.token_type == TokenType.true_keyword)
  end
end

return BooleanLiteralExpression
