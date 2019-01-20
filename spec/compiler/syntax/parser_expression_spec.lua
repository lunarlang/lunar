local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local NilLiteralExpression = require "lunar.ast.exprs.nil_literal_expression"

describe("Parser:parse_expression", function()
  it("should return one NilLiteralExpression node", function()
    local tokens = Lexer.new("nil"):tokenize()
    local ast = Parser.new(tokens):parse_expression()

    assert.same(NilLiteralExpression.new(), ast)
  end)
end)
