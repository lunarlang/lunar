local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local NilLiteralExpression = require "lunar.ast.exprs.nil_literal_expression"
local BooleanLiteralExpression = require "lunar.ast.exprs.boolean_literal_expression"
local NumberLiteralExpression = require "lunar.ast.exprs.number_literal_expression"

describe("Parser:parse_expression", function()
  it("should return one NilLiteralExpression node", function()
    local tokens = Lexer.new("nil"):tokenize()
    local ast = Parser.new(tokens):parse_expression()

    assert.same(NilLiteralExpression.new(), ast)
  end)

  it("should return one BooleanLiteralExpression node given a value of true", function()
    local tokens = Lexer.new("true"):tokenize()
    local ast = Parser.new(tokens):parse_expression()

    assert.same(BooleanLiteralExpression.new(true), ast)
  end)

  it("should return one BooleanLiteralExpression node given a value of false", function()
    local tokens = Lexer.new("false"):tokenize()
    local ast = Parser.new(tokens):parse_expression()

    assert.same(BooleanLiteralExpression.new(false), ast)
  end)

  it("should return one NumberLiteralExpression node given a value of 100", function()
    local tokens = Lexer.new("100"):tokenize()
    local ast = Parser.new(tokens):parse_expression()

    assert.same(NumberLiteralExpression.new(100), ast)
  end)
end)
