local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("LiteralExpression syntax", function()
  it("should return one NilLiteralExpression node", function()
    local tokens = Lexer.new("nil"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.NilLiteralExpression.new(), result)
  end)

  it("should return one BooleanLiteralExpression node given a value of true", function()
    local tokens = Lexer.new("true"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.BooleanLiteralExpression.new(true), result)
  end)

  it("should return one BooleanLiteralExpression node given a value of false", function()
    local tokens = Lexer.new("false"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.BooleanLiteralExpression.new(false), result)
  end)

  it("should return one NumberLiteralExpression node given a value of 100", function()
    local tokens = Lexer.new("100"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.NumberLiteralExpression.new(100), result)
  end)

  it("should return one StringLiteralExpression node given a string value", function()
    local tokens = Lexer.new("'Hello, world!'"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.StringLiteralExpression.new("'Hello, world!'"), result)
  end)

  it("should return one VariableArgumentExpression node", function()
    local tokens = Lexer.new("..."):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.VariableArgumentExpression.new(), result)
  end)

  it("should return one FunctionExpression node whose parameters has two ParameterDeclaration nodes and a BreakStatement block", function()
    local tokens = Lexer.new("function(hello, ...) break end"):tokenize()
    local result = Parser.new(tokens):expression()

    local expected_params = { AST.ParameterDeclaration.new("hello"), AST.ParameterDeclaration.new("...") }
    local expected_block = { AST.BreakStatement.new() }

    assert.same(AST.FunctionExpression.new(expected_params, expected_block), result)
  end)

  it("should return one TableLiteralExpression node with three FieldDeclaration nodes", function()
    local tokens = Lexer.new("{ ['hello'] = true, world = false; nil; }"):tokenize()
    local result = Parser.new(tokens):expression()

    local expected_fields = {
      AST.FieldDeclaration.new(AST.StringLiteralExpression.new("'hello'"), AST.BooleanLiteralExpression.new(true)),
      AST.FieldDeclaration.new(TokenInfo.new(TokenType.identifier, "world", 21), AST.BooleanLiteralExpression.new(false)),
      AST.FieldDeclaration.new(nil, AST.NilLiteralExpression.new()),
    }

    assert.same(AST.TableLiteralExpression.new(expected_fields), result)
  end)
end)
