local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("Parser:parse_expression", function()
  describe("LiteralExpression syntax", function()
    it("should return one NilLiteralExpression node", function()
      local tokens = Lexer.new("nil"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.NilLiteralExpression.new(), ast)
    end)

    it("should return one BooleanLiteralExpression node given a value of true", function()
      local tokens = Lexer.new("true"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.BooleanLiteralExpression.new(true), ast)
    end)

    it("should return one BooleanLiteralExpression node given a value of false", function()
      local tokens = Lexer.new("false"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.BooleanLiteralExpression.new(false), ast)
    end)

    it("should return one NumberLiteralExpression node given a value of 100", function()
      local tokens = Lexer.new("100"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.NumberLiteralExpression.new(100), ast)
    end)

    it("should return one StringLiteralExpression node given a string value", function()
      local tokens = Lexer.new("'Hello, world!'"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.StringLiteralExpression.new("'Hello, world!'"), ast)
    end)

    it("should return one VariableArgumentExpression node", function()
      local tokens = Lexer.new("..."):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      assert.same(AST.VariableArgumentExpression.new(), ast)
    end)

    it("should return one FunctionExpression node whose parameters has two ParameterDeclaration nodes and a BreakStatement block", function()
      local tokens = Lexer.new("function(hello, ...) break end"):tokenize()
      local ast = Parser.new(tokens):parse_expression()

      local expected_params = { AST.ParameterDeclaration.new("hello"), AST.ParameterDeclaration.new("...") }
      local expected_block = { AST.BreakStatement.new() }

      assert.same(AST.FunctionExpression.new(expected_params, expected_block), ast)
    end)
  end)

  describe("ExpressionList syntax", function()
    it("should return one ExpressionList with two expression nodes", function()
      local tokens = Lexer.new("1, 2"):tokenize()
      local ast = Parser.new(tokens):parse_expression_list()

      assert.same(AST.ExpressionList.new(AST.NumberLiteralExpression.new(1), AST.NumberLiteralExpression.new(2)), ast)
    end)
  end)
end)
