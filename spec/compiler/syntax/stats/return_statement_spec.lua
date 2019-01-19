local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local ReturnStatement = require "lunar.ast.stats.return_statement"
local NilLiteralExpression = require "lunar.ast.exprs.nil_literal_expression"

describe("ReturnStatement syntax", function()
  it("should only return one ReturnStatement node", function()
    local tokens = Lexer.new("return"):tokenize()
    local ast = Parser.new(tokens):parse()

    assert.same({
      ReturnStatement.new()
    }, ast)
  end)

  it("should return one ReturnStatement node with one expression", function()
    local tokens = Lexer.new("return nil"):tokenize()
    local ast = Parser.new(tokens):parse()

    assert.same({
      ReturnStatement.new(NilLiteralExpression.new())
    }, ast)
  end)

  it("should return one ReturnStatement node with two expressions", function()
    local tokens = Lexer.new("return nil, nil"):tokenize()
    local ast = Parser.new(tokens):parse()

    assert.same({
      ReturnStatement.new(NilLiteralExpression.new(), NilLiteralExpression.new())
    }, ast)
  end)
end)
