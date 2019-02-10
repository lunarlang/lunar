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
  -- 'do' block 'end'
  if self:match(TokenType.do_keyword) then
    local block = self:parse_block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'do'")

    return AST.DoStatement.new(unpack(block))
  end
end

function Parser:parse_last_statement()
  -- 'break'
  if self:match(TokenType.break_keyword) then
    return AST.BreakStatement.new()
  end

  -- 'return' [explist]
  if self:match(TokenType.return_keyword) then
    local explist = self:parse_expression_list()

    -- prefer nil if there is no expressions
    if #explist == 0 then
      return AST.ReturnStatement.new(nil)
    end

    return AST.ReturnStatement.new(explist)
  end
end

function Parser:parse_expression()
  -- 'nil'
  if self:match(TokenType.nil_keyword) then
    return AST.NilLiteralExpression.new()
  end

  -- 'true' | 'false'
  if self:assert(TokenType.true_keyword, TokenType.false_keyword) then
    local boolean_token = self:consume()
    return AST.BooleanLiteralExpression.new(boolean_token.token_type == TokenType.true_keyword)
  end

  -- number
  if self:assert(TokenType.number) then
    local number_token = self:consume()
    return AST.NumberLiteralExpression.new(tonumber(number_token.value))
  end

  -- string
  if self:assert(TokenType.string) then
    local string_token = self:consume()
    return AST.StringLiteralExpression.new(string_token.value)
  end

  -- '{' [fieldlist] '}'
  if self:match(TokenType.left_brace) then
    local fieldlist = self:parse_field_list()
    self:expect(TokenType.right_brace, "Expected '}' to close '{'")

    return AST.TableLiteralExpression.new(fieldlist)
  end

  -- '...'
  if self:match(TokenType.triple_dot) then
    return AST.VariableArgumentExpression.new()
  end

  -- 'function' '(' [paramlist] ')' block 'end'
  if self:match(TokenType.function_keyword) then
    self:expect(TokenType.left_paren, "Expected '(' to start 'function'")
    local paramlist = self:parse_parameter_list()
    self:expect(TokenType.right_paren, "Expected ')' to close '('")
    local block = self:parse_block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'function'")

    return AST.FunctionExpression.new(paramlist, block)
  end
end

function Parser:parse_expression_list()
  -- exp {',' exp}
  local explist = {}

  repeat
    local expr = self:parse_expression()

    if expr ~= nil then
      table.insert(explist, expr)
    end
  until not self:match(TokenType.comma)

  return explist
end

function Parser:parse_parameter_declaration()
  -- identifier | '...'
  if self:assert(TokenType.identifier, TokenType.triple_dot) then
    local param = self:consume()
    return AST.ParameterDeclaration.new(param.value)
  end
end

function Parser:parse_parameter_list()
  -- param {',' param} [',' '...']
  -- keep parsing params until we see '...' or there's no ','
  local paramlist = {}
  local param

  repeat
    param = self:parse_parameter_declaration()
    if param ~= nil then
      table.insert(paramlist, param)
    end
  until not self:match(TokenType.comma) or param.name == "..."

  return paramlist
end

function Parser:parse_field_declaration()
  -- '[' exp ']' '=' exp
  if self:match(TokenType.left_bracket) then
    local key = self:parse_expression()
    self:expect(TokenType.right_bracket, "Expected ']' to close '['")
    self:expect(TokenType.equal, "Expected '=' near ']'")
    local value = self:parse_expression()

    return AST.FieldDeclaration.new(key, value)
  end

  -- identifier '=' exp
  if self:peek(1) and self:peek(1).token_type == TokenType.equal then
    local key = self:expect(TokenType.identifier, "Expected identifier to start this field")
    self:consume() -- consumes the equal token, because we asserted it earlier
    local value = self:parse_expression()

    return AST.FieldDeclaration.new(key, value)
  end

  -- exp
  local value = self:parse_expression()
  if value ~= nil then
    return AST.FieldDeclaration.new(nil, value)
  end
end

function Parser:parse_field_list()
  -- field {(',' | ';') field} [(',' | ';')]
  local fieldlist = {}
  local lastfield

  repeat
    lastfield = self:parse_field_declaration()

    if lastfield ~= nil then
      table.insert(fieldlist, lastfield)
      self:match(TokenType.comma, TokenType.semi_colon)
    end
  until lastfield == nil

  return fieldlist
end

return Parser
