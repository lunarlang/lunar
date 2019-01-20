local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local NilLiteralExpression = require "lunar.ast.exprs.nil_literal_expression"
local TrueLiteralExpression = require "lunar.ast.exprs.true_literal_expression"
local FalseLiteralExpression = require "lunar.ast.exprs.false_literal_expression"

describe("Parser:parse_expression", function()
  it("should return one NilLiteralExpression node", function()
    local tokens = Lexer.new("nil"):tokenize()
    local ast = Parser.new(tokens):parse_expression()

    assert.same(NilLiteralExpression.new(), ast)
  end)

  it("should return one TrueLiteralExpression node", function()
    local tokens = Lexer.new("true"):tokenize()
    local ast = Parser.new(tokens):parse_expression()

    assert.same(TrueLiteralExpression.new(), ast)
  end)

  it("should return one FalseLiteralExpression node", function()
    local tokens = Lexer.new("false"):tokenize()
    local ast = Parser.new(tokens):parse_expression()

    assert.same(FalseLiteralExpression.new(), ast)
  end)
end)
