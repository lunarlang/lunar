local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local UnaryExpression = setmetatable({}, SyntaxNode)
UnaryExpression.__index = UnaryExpression

function UnaryExpression.new(operator, operand)
  local super = SyntaxNode.new(SyntaxKind.unary_expression)
  local self = setmetatable(super, UnaryExpression)
  self.operator = operator
  self.operand = operand

  return self
end

function UnaryExpression.try_parse(parser)
  if parser:assert(TokenType.minus, TokenType.not_keyword, TokenType.pound) then
    local operator = parser:consume()
    local right = parser:parse_unary()

    return UnaryExpression.new(operator, right)
  end

  return parser:parse_primary_expression()
end

return UnaryExpression
