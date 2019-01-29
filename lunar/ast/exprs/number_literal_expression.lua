local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local NumberLiteralExpression = setmetatable({}, SyntaxNode)
NumberLiteralExpression.__index = NumberLiteralExpression

function NumberLiteralExpression.new(value)
  local super = SyntaxNode.new(SyntaxKind.number_literal_expression)
  local self = setmetatable(super, NumberLiteralExpression)
  self.value = value

  return self
end

function NumberLiteralExpression.try_parse(parser)
  if parser:assert(TokenType.number) then
    local token = parser:consume()

    return NumberLiteralExpression.new(tonumber(token.value))
  end
end

return NumberLiteralExpression
