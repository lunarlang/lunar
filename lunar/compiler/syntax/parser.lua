local AST = require "lunar.ast"
local BaseParser = require "lunar.compiler.syntax.base_parser"
local TokenType = require "lunar.compiler.lexical.token_type"

local Parser = setmetatable({}, BaseParser)
Parser.__index = Parser

function Parser.new(tokens)
  local super = BaseParser.new(tokens)
  local self = setmetatable(super, Parser)

  return self
end

function Parser:parse()
  return self:parse_block()
end

function Parser:parse_block()
  local stats = {}

  while not self:is_finished() do
    local stat = self:parse_statement()
    if stat ~= nil then
      table.insert(stats, stat)
      self:match(TokenType.semi_colon)
    end

    local last = self:parse_last_statement()
    if last ~= nil then
      table.insert(stats, last)
      self:match(TokenType.semi_colon)
      break
    end

    if (stat or last) == nil then
      break
    end
  end

  return stats
end

function Parser:parse_statement()
  if self:match(TokenType.do_keyword) then
    local block = self:parse_block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'do'")
    return AST.DoStatement.new(unpack(block))
  end
end

function Parser:parse_last_statement()
  if self:match(TokenType.break_keyword) then
    return AST.BreakStatement.new()
  elseif self:match(TokenType.return_keyword) then
    local explist = self:parse_expression_list()
    return AST.ReturnStatement.new(#explist.expressions > 0 and explist or nil) -- prefer nil over empty explist
  end
end

function Parser:parse_expression()
  if self:match(TokenType.nil_keyword) then
    return AST.NilLiteralExpression.new()
  elseif self:match(TokenType.true_keyword, TokenType.false_keyword) then
    local token = self:peek(-1)
    return AST.BooleanLiteralExpression.new(token.token_type == TokenType.true_keyword)
  elseif self:match(TokenType.number) then
    local token = self:peek(-1)
    return AST.NumberLiteralExpression.new(tonumber(token.value))
  end
end

function Parser:parse_expression_list()
  local explist = {}

  repeat
    local expr = self:parse_expression()

    if expr then
      table.insert(explist, expr)
    end
  until not self:match(TokenType.comma)

  return AST.ExpressionList.new(unpack(explist))
end

return Parser
