local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local FunctionExpression = setmetatable({}, SyntaxNode)
FunctionExpression.__index = FunctionExpression

function FunctionExpression.new(parameters, block)
  local super = SyntaxNode.new(SyntaxKind.function_expression)
  local self = setmetatable(super, FunctionExpression)
  self.parameters = parameters
  self.block = block

  return self
end

function FunctionExpression.try_parse(parser)
  if parser:match(TokenType.function_keyword) then
    parser:expect(TokenType.left_paren, "Expected '(' to start 'function'")
    local params = parser:parse_parameter_list()
    parser:expect(TokenType.right_paren, "Expected ')' to close '('")
    local block = parser:parse_block()
    parser:expect(TokenType.end_keyword, "Expected 'end' to close 'function'")

    return FunctionExpression.new(params, block)
  end
end

return FunctionExpression
