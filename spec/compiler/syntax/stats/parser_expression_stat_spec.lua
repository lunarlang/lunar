local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("ExpressionStatement syntax", function()
  it("should return one ExpressionStatement node with an expression of FunctionCallExpression", function()
    local tokens = Lexer.new("hello()"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.ExpressionStatement.new(AST.FunctionCallExpression.new(AST.MemberExpression.new("hello"), {}))
    }, result)
  end)
end)
