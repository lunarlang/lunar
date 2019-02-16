local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("ReturnStatement syntax", function()
  it("should only return one ReturnStatement node", function()
    local tokens = Lexer.new("return"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({ AST.ReturnStatement.new() }, result)
  end)

  it("should return one ReturnStatement node with one expression", function()
    local tokens = Lexer.new("return nil"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_expr_list = { AST.NilLiteralExpression.new() }

    assert.same({ AST.ReturnStatement.new(expected_expr_list) }, result)
  end)

  it("should return one ReturnStatement node with two expressions", function()
    local tokens = Lexer.new("return nil, nil"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_expr_list = { AST.NilLiteralExpression.new(), AST.NilLiteralExpression.new() }

    assert.same({ AST.ReturnStatement.new(expected_expr_list) }, result)
  end)
end)
