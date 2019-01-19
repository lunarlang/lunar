local BaseParser = require "lunar.compiler.syntax.base_parser"
local TokenType = require "lunar.compiler.lexical.token_type"
local BreakStatement = require "lunar.ast.stats.break_statement"
local ReturnStatement = require "lunar.ast.stats.return_statement"
local DoStatement = require "lunar.ast.stats.do_statement"
local NilLiteralExpression = require "lunar.ast.exprs.nil_literal_expression"

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
      self:match_any(TokenType.semi_colon)
    end

    local last = self:parse_last_statement()
    if last ~= nil then
      table.insert(stats, last)
      self:match_any(TokenType.semi_colon)
      break
    end

    if (stat or last) == nil then
      break
    end
  end

  return stats
end

function Parser:parse_statement()
  return self:parse_do_statement()
end

function Parser:parse_last_statement()
  if self:match_any(TokenType.break_keyword) then
    return BreakStatement.new()
  elseif self:match_any(TokenType.return_keyword) then
    -- TODO: explist
    return ReturnStatement.new()
  end
end

function Parser:parse_do_statement()
  if self:match_any(TokenType.do_keyword) then
    local block = self:parse_block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'do'")
    return DoStatement.new(unpack(block))
  end
end

function Parser:parse_expression()
  if self:match_any(TokenType.nil_keyword) then
    return NilLiteralExpression.new()
  end
end

return Parser
