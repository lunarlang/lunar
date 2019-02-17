local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("VariableStatement syntax", function()
  it("should return one VariableSyntax node with two names and two expressions", function()
    local tokens = Lexer.new("local a, b = 1, 2"):tokenize()
    local result = Parser.new(tokens):parse()

    local names = { "a", "b" }
    local exprs = {
      AST.NumberLiteralExpression.new(1),
      AST.NumberLiteralExpression.new(2)
    }

    assert.same({ AST.VariableStatement.new(names, exprs) }, result)
  end)

  it("should return one VariableSyntax node with two names and one expression", function()
    local tokens = Lexer.new("local a, b = ..."):tokenize()
    local result = Parser.new(tokens):parse()

    local names = { "a", "b" }
    local exprs = { AST.VariableArgumentExpression.new() }

    assert.same({ AST.VariableStatement.new(names, exprs) }, result)
  end)

  it("should return one VariableSyntax node with one name and no expression", function()
    local tokens = Lexer.new("local a"):tokenize()
    local result = Parser.new(tokens):parse()

    local names = { "a" }

    assert.same({ AST.VariableStatement.new(names) }, result)
  end)

  it("should return two VariableSyntax node with one name and one expression, each", function()
    local tokens = Lexer.new("local a = 1 local b = 2"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.VariableStatement.new({ "a" }, { AST.NumberLiteralExpression.new(1) }),
      AST.VariableStatement.new({ "b" }, { AST.NumberLiteralExpression.new(2) })
    }, result)
  end)
end)
