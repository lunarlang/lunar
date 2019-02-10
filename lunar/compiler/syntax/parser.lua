local AST = require "lunar.ast"
local BaseParser = require "lunar.compiler.syntax.base_parser"
local TokenType = require "lunar.compiler.lexical.token_type"

local Parser = setmetatable({}, BaseParser)
Parser.__index = Parser

function Parser.new(tokens)
  local super = BaseParser.new(tokens)
  local self = setmetatable(super, Parser)

  self.binary_op_map = {
    ["+"] = AST.BinaryOpKind.addition_op,
    ["-"] = AST.BinaryOpKind.subtraction_op,
    ["*"] = AST.BinaryOpKind.multiplication_op,
    ["/"] = AST.BinaryOpKind.division_op,
    ["%"] = AST.BinaryOpKind.modulus_op,
    ["^"] = AST.BinaryOpKind.power_op,
    [".."] = AST.BinaryOpKind.concatenation_op,
    ["~="] = AST.BinaryOpKind.not_equal_op,
    ["=="] = AST.BinaryOpKind.equal_op,
    ["<"] = AST.BinaryOpKind.less_than_op,
    ["<="] = AST.BinaryOpKind.less_or_equal_op,
    [">"] = AST.BinaryOpKind.greater_than_op,
    [">="] = AST.BinaryOpKind.greater_or_equal_op,
    ["and"] = AST.BinaryOpKind.and_op,
    ["or"] = AST.BinaryOpKind.or_op,
  }

  self.unary_op_map = {
    ["not"] = AST.UnaryOpKind.not_op,
    ["-"] = AST.UnaryOpKind.negative_op,
    ["#"] = AST.UnaryOpKind.length_op,
  }

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
  return self:parse_logical_or_expression()
end

-- it looks like the opposite of operator precedences even though we're parsing our way downwards
-- that's because we start from the lowest operator precedence and work our way up to the highest operator precedence
function Parser:parse_logical_or_expression()
  -- logical_and {'or' logical_and}
  local expr = self:parse_logical_and_expression()

  while self:assert(TokenType.or_keyword) do
    local op = self:consume()
    local right = self:parse_logical_and_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:parse_logical_and_expression()
  -- comparison {('and') comparison}
  local expr = self:parse_comparison_expression()

  while self:assert(TokenType.and_keyword) do
    local op = self:consume()
    local right = self:parse_comparison_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:parse_comparison_expression()
  -- concat {('~=' | '==' | '<' | '<=' | '>' | '>=') concat}
  local expr = self:parse_concat_expression()

  while self:assert(
    TokenType.tilde_equal,
    TokenType.double_equal,
    TokenType.left_angle,
    TokenType.left_angle_equal,
    TokenType.right_angle,
    TokenType.right_angle_equal
  ) do
    local op = self:consume()
    local right = self:parse_concat_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:parse_concat_expression()
  -- right associativity
  -- addition {('..') concat}
  local expr = self:parse_addition_expression()

  while self:assert(TokenType.double_dot) do
    local op = self:consume()
    local right = self:parse_concat_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:parse_addition_expression()
  -- multiplication {('+' | '-') multiplication}
  local expr = self:parse_multiplication_expression()

  while self:assert(TokenType.plus, TokenType.minus) do
    local op = self:consume()
    local right = self:parse_multiplication_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:parse_multiplication_expression()
  -- power {('*' | '/' | '%') power}
  local expr = self:parse_power_expression()

  while self:assert(TokenType.asterisk, TokenType.slash, TokenType.percent) do
    local op = self:consume()
    local right = self:parse_power_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:parse_power_expression()
  -- right associativity
  -- unary {'^' power}
  local expr = self:parse_unary_expression()

  while self:assert(TokenType.caret) do
    local op = self:consume()
    local right = self:parse_power_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:parse_unary_expression()
  -- ('not' | '-' | '#') unary | primary
  if self:assert(TokenType.not_keyword, TokenType.minus, TokenType.pound) then
    local op = self:consume()
    local right = self:parse_unary_expression()
    return AST.UnaryOpExpression.new(self.unary_op_map[op.value], right)
  end

  return self:parse_primary_expression()
end

function Parser:parse_primary_expression()
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
