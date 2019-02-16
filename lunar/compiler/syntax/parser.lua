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
  return self:block()
end

function Parser:block()
  local stats = {}

  while not self:is_finished() do
    local stat = self:statement()
    if stat ~= nil then
      table.insert(stats, stat)
      self:match(TokenType.semi_colon)
    end

    local last = self:last_statement()
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

function Parser:statement()
  -- 'do' block 'end'
  if self:match(TokenType.do_keyword) then
    local block = self:block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'do'")

    return AST.DoStatement.new(unpack(block))
  end
end

function Parser:last_statement()
  -- 'break'
  if self:match(TokenType.break_keyword) then
    return AST.BreakStatement.new()
  end

  -- 'return' [explist]
  if self:match(TokenType.return_keyword) then
    local explist = self:expression_list()

    -- prefer nil if there is no expressions
    if #explist == 0 then
      return AST.ReturnStatement.new(nil)
    end

    return AST.ReturnStatement.new(explist)
  end
end

function Parser:function_arg()
  -- exp
  local exp = self:expression()
  if exp ~= nil then
    return AST.ArgumentExpression.new(exp)
  end
end

function Parser:function_arg_list()
  -- '(' arg {',' arg} ')'
  if self:match(TokenType.left_paren) then
    local args = {}

    repeat
      local arg = self:function_arg()

      if arg ~= nil then
        table.insert(args, arg)
      end
    until not self:match(TokenType.comma)

    self:expect(TokenType.right_paren, "Expected ')' to close '('")

    return args
  end

  -- string | TableLiteralExpression
  if self:assert(TokenType.string, TokenType.left_brace) then
    return { self:function_arg() }
  end
end

function Parser:prefix_expression()
  -- '(' exp ')'
  if self:match(TokenType.left_paren) then
    local exp = self:expression()
    self:expect(TokenType.right_paren, "Expected ')' to close '('")

    return exp
  end

  -- identifier
  if self:assert(TokenType.identifier) then
    return AST.MemberExpression.new(self:consume(), nil)
  end
end

function Parser:expression()
  return self:logical_or_expression()
end

-- it looks like the opposite of operator precedences even though we're parsing our way downwards
-- that's because we start from the lowest operator precedence and work our way up to the highest operator precedence
function Parser:logical_or_expression()
  -- logical_and {'or' logical_and}
  local expr = self:logical_and_expression()

  while self:assert(TokenType.or_keyword) do
    local op = self:consume()
    local right = self:logical_and_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:logical_and_expression()
  -- comparison {('and') comparison}
  local expr = self:comparison_expression()

  while self:assert(TokenType.and_keyword) do
    local op = self:consume()
    local right = self:comparison_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:comparison_expression()
  -- concat {('~=' | '==' | '<' | '<=' | '>' | '>=') concat}
  local expr = self:concat_expression()

  while self:assert(
    TokenType.tilde_equal,
    TokenType.double_equal,
    TokenType.left_angle,
    TokenType.left_angle_equal,
    TokenType.right_angle,
    TokenType.right_angle_equal
  ) do
    local op = self:consume()
    local right = self:concat_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:concat_expression()
  -- right associativity
  -- addition {('..') concat}
  local expr = self:addition_expression()

  while self:assert(TokenType.double_dot) do
    local op = self:consume()
    local right = self:concat_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:addition_expression()
  -- multiplication {('+' | '-') multiplication}
  local expr = self:multiplication_expression()

  while self:assert(TokenType.plus, TokenType.minus) do
    local op = self:consume()
    local right = self:multiplication_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:multiplication_expression()
  -- power {('*' | '/' | '%') power}
  local expr = self:power_expression()

  while self:assert(TokenType.asterisk, TokenType.slash, TokenType.percent) do
    local op = self:consume()
    local right = self:power_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:power_expression()
  -- right associativity
  -- unary {'^' power}
  local expr = self:unary_expression()

  while self:assert(TokenType.caret) do
    local op = self:consume()
    local right = self:power_expression()
    expr = AST.BinaryOpExpression.new(expr, self.binary_op_map[op.value], right)
  end

  return expr
end

function Parser:unary_expression()
  -- ('not' | '-' | '#') unary | primary
  if self:assert(TokenType.not_keyword, TokenType.minus, TokenType.pound) then
    local op = self:consume()
    local right = self:unary_expression()
    return AST.UnaryOpExpression.new(self.unary_op_map[op.value], right)
  end

  return self:primary_expression()
end

function Parser:primary_expression()
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
    local fieldlist = self:field_list()
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
    local paramlist = self:parameter_list()
    self:expect(TokenType.right_paren, "Expected ')' to close '('")
    local block = self:block()
    self:expect(TokenType.end_keyword, "Expected 'end' to close 'function'")

    return AST.FunctionExpression.new(paramlist, block)
  end

  return self:secondary_expression()
end

function Parser:secondary_expression()
  local prefixexp = self:prefix_expression()

  if prefixexp ~= nil then
    -- prefixexp '.' identifier
    if self:match(TokenType.dot) then
      local identifier_token = self:expect(TokenType.identifier, "Expected identifier after '.'")
      return AST.MemberExpression.new(prefixexp, identifier_token)
    end

    -- prefixexp '[' exp ']'
    if self:match(TokenType.left_bracket) then
      local exp = self:expression()
      return AST.MemberExpression.new(prefixexp, exp)
    end

    -- prefixexp ':' identifier arglist
    if self:match(TokenType.colon) then
      local identifier_token = self:expect(TokenType.identifier)
      local args = self:function_arg_list()
      return AST.FunctionCallExpression.new(AST.MemberExpression.new(prefixexp, identifier_token, true), args)
    end

    -- prefixexp arglist
    if self:assert(TokenType.left_paren, TokenType.string, TokenType.left_brace) then
      local args = self:function_arg_list()
      return AST.FunctionCallExpression.new(prefixexp, args)
    end

    -- prefixexp
    return prefixexp
  end
end

function Parser:expression_list()
  -- exp {',' exp}
  local explist = {}

  repeat
    local expr = self:expression()

    if expr ~= nil then
      table.insert(explist, expr)
    end
  until not self:match(TokenType.comma)

  return explist
end

function Parser:parameter_declaration()
  -- identifier | '...'
  if self:assert(TokenType.identifier, TokenType.triple_dot) then
    local param = self:consume()
    return AST.ParameterDeclaration.new(param.value)
  end
end

function Parser:parameter_list()
  -- param {',' param} [',' '...']
  -- keep parsing params until we see '...' or there's no ','
  local paramlist = {}
  local param

  repeat
    param = self:parameter_declaration()
    if param ~= nil then
      table.insert(paramlist, param)
    end
  until not self:match(TokenType.comma) or param.name == "..."

  return paramlist
end

function Parser:field_declaration()
  -- '[' exp ']' '=' exp
  if self:match(TokenType.left_bracket) then
    local key = self:expression()
    self:expect(TokenType.right_bracket, "Expected ']' to close '['")
    self:expect(TokenType.equal, "Expected '=' near ']'")
    local value = self:expression()

    return AST.FieldDeclaration.new(key, value)
  end

  -- identifier '=' exp
  if self:peek(1) and self:peek(1).token_type == TokenType.equal then
    local key = self:expect(TokenType.identifier, "Expected identifier to start this field")
    self:consume() -- consumes the equal token, because we asserted it earlier
    local value = self:expression()

    return AST.FieldDeclaration.new(key, value)
  end

  -- exp
  local value = self:expression()
  if value ~= nil then
    return AST.FieldDeclaration.new(nil, value)
  end
end

function Parser:field_list()
  -- field {(',' | ';') field} [(',' | ';')]
  local fieldlist = {}
  local lastfield

  repeat
    lastfield = self:field_declaration()

    if lastfield ~= nil then
      table.insert(fieldlist, lastfield)
      self:match(TokenType.comma, TokenType.semi_colon)
    end
  until lastfield == nil

  return fieldlist
end

return Parser
