local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("RangeForStatement syntax", function()
  it("should return one RangeForStatement node with two expressions", function()
    local tokens = Lexer.new("for i = 1, 2 do end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.RangeForStatement.new(
        "i",
        AST.NumberLiteralExpression.new(1),
        AST.NumberLiteralExpression.new(2),
        nil,
        {}
      )
    }, result)
  end)

  it("should return one RangeForStatement node with three expressions", function()
    local tokens = Lexer.new("for i = 1, 2, 3 do end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.RangeForStatement.new(
        "i",
        AST.NumberLiteralExpression.new(1),
        AST.NumberLiteralExpression.new(2),
        AST.NumberLiteralExpression.new(3),
        {}
      )
    }, result)
  end)
end)
