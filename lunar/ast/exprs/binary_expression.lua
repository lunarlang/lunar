local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local BinaryExpression = setmetatable({}, SyntaxNode)
BinaryExpression.__index = BinaryExpression

function BinaryExpression.new(left_operand, operator, right_operand)
  local super = SyntaxNode.new(SyntaxKind.binary_expression)
  local self = setmetatable(super, BinaryExpression)
  self.left_operand = left_operand
  self.operator = operator
  self.right_operand = right_operand

  return self
end

function BinaryExpression.try_parse(parser)
  return BinaryExpression.try_parse_equality(parser)
end

function BinaryExpression.try_parse_equality(parser)
  local expr = BinaryExpression.try_parse_comparison(parser)

  while parser:assert(TokenType.double_equal, TokenType.tilde_equal) do
    local operator = parser:consume()
    local right = BinaryExpression.try_parse_comparison(parser)
    expr = BinaryExpression.new(expr, operator, right)
  end

  return expr
end

function BinaryExpression.try_parse_comparison(parser)
  local expr = BinaryExpression.try_parse_addition(parser)

  while parser:assert(TokenType.right_angle, TokenType.right_angle_equal, TokenType.left_angle, TokenType.left_angle_equal) do
    local operator = parser:consume()
    local right = BinaryExpression.try_parse_addition(parser)
    expr = BinaryExpression.new(expr, operator, right)
  end

  return expr
end

function BinaryExpression.try_parse_addition(parser)
  local expr = BinaryExpression.try_parse_multiplication(parser)

  while parser:assert(TokenType.plus, TokenType.minus) do
    local operator = parser:consume()
    local right = BinaryExpression.try_parse_multiplication(parser)
    expr = BinaryExpression.new(expr, operator, right)
  end

  return expr
end

function BinaryExpression.try_parse_multiplication(parser)
  local expr = parser:parse_unary()

  while parser:assert(TokenType.asterisk, TokenType.slash) do
    local operator = parser:consume()
    local right = parser:parse_unary()
    expr = BinaryExpression.new(expr, operator, right)
  end

  return expr
end

return BinaryExpression
