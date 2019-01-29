local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local NilLiteralExpression = setmetatable({}, SyntaxNode)
NilLiteralExpression.__index = NilLiteralExpression

function NilLiteralExpression.new()
  local super = SyntaxNode.new(SyntaxKind.nil_literal_expression)
  local self = setmetatable(super, NilLiteralExpression)

  return self
end

function NilLiteralExpression.try_parse(parser)
  if parser:match(TokenType.nil_keyword) then
    return NilLiteralExpression.new()
  end
end

return NilLiteralExpression
