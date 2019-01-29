local SyntaxKind = require "lunar.ast.syntax_kind"
local SyntaxNode = require "lunar.ast.syntax_node"
local TokenType = require "lunar.compiler.lexical.token_type"

local ExpressionList = setmetatable({}, SyntaxNode)
ExpressionList.__index = ExpressionList

function ExpressionList.new(...)
  local super = SyntaxNode.new(SyntaxKind.expression_list)
  local self = setmetatable(super, ExpressionList)
  self.expressions = { ... }

  return self
end

function ExpressionList.try_parse(parser)
  local explist = {}

  repeat
    local expr = parser:parse_expression()

    if expr ~= nil then
      table.insert(explist, expr)
    end
  until not parser:match(TokenType.comma)

  return ExpressionList.new(unpack(explist))
end

return ExpressionList
