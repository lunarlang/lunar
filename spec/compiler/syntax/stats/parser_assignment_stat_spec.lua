local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("AssignmentStatement syntax", function()
  it("should return one AssignmentStatement with one MemberExpression and one expression", function()
    local tokens = Lexer.new("hello = 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local members = { AST.MemberExpression.new("hello") }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(members, exprs) }, result)
  end)

  it("should return one AssignmentStatement with one MemberExpression using bracket notation and one expression", function()
    local tokens = Lexer.new("hello['world'] = 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local members = { AST.MemberExpression.new(AST.MemberExpression.new("hello"), AST.StringLiteralExpression.new("'world'")) }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(members, exprs) }, result)
  end)

  it("should return one AssignmentStatement with one MemberExpression using dot notation and one expression", function()
    local tokens = Lexer.new("hello.world = 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local members = { AST.MemberExpression.new(AST.MemberExpression.new("hello"), "world") }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(members, exprs) }, result)
  end)

  it("should return one AssignmentStatement with two MemberExpression and one expression", function()
    local tokens = Lexer.new("hello, world = ..."):tokenize()
    local result = Parser.new(tokens):parse()

    local members = { AST.MemberExpression.new("hello"), AST.MemberExpression.new("world") }
    local exprs = { AST.VariableArgumentExpression.new() }

    assert.same({ AST.AssignmentStatement.new(members, exprs) }, result)
  end)

  it("should throw an error given an invalid left-hand side member", function()
    local tokens = Lexer.new("hi() = 1"):tokenize()

    local parse = function()
      Parser.new(tokens):parse()
    end

    assert.errors(parse, "Unexpected token '=' at 6")
  end)
end)
