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
  return AST.DoStatement.try_parse(self)
end

function Parser:parse_last_statement()
  return AST.BreakStatement.try_parse(self)
      or AST.ReturnStatement.try_parse(self)
end

function Parser:parse_expression()
  return AST.NilLiteralExpression.try_parse(self)
      or AST.BooleanLiteralExpression.try_parse(self)
      or AST.NumberLiteralExpression.try_parse(self)
      or AST.StringLiteralExpression.try_parse(self)
      or AST.TableLiteralExpression.try_parse(self)
      or AST.VariableArgumentExpression.try_parse(self)
      or AST.FunctionExpression.try_parse(self)
end

function Parser:parse_expression_list()
  return AST.ExpressionList.try_parse(self)
end

function Parser:parse_parameter_list()
  local paramlist = {}

  repeat
    local param = AST.ParameterDeclaration.try_parse(self)
    if param ~= nil then
      table.insert(paramlist, param)

      -- ... is the final argument possible in a list of parameters
      if param.name == "..." then
        break
      end
    end
  until not self:match(TokenType.comma)

  return paramlist
end

function Parser:parse_field_list()
  local fieldlist = {}

  repeat
    lastfield = AST.FieldDeclaration.try_parse(self)

    if lastfield ~= nil then
      table.insert(fieldlist, lastfield)
      self:match(TokenType.comma, TokenType.semi_colon)
    end
  until lastfield == nil

  return fieldlist
end

return Parser
