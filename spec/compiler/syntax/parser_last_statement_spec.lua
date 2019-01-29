local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("Parser:parse_last_statement", function()
  describe("BreakStatement syntax", function()
    it("should only return one BreakStatement node", function()
      local tokens = Lexer.new("break"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        AST.BreakStatement.new()
      }, ast)
    end)
  end)

  describe("ReturnStatement syntax", function()
    it("should only return one ReturnStatement node", function()
      local tokens = Lexer.new("return"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        AST.ReturnStatement.new()
      }, ast)
    end)

    it("should return one ReturnStatement node with one expression", function()
      local tokens = Lexer.new("return nil"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        AST.ReturnStatement.new(AST.ExpressionList.new(AST.NilLiteralExpression.new()))
      }, ast)
    end)

    it("should return one ReturnStatement node with two expressions", function()
      local tokens = Lexer.new("return nil, nil"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        AST.ReturnStatement.new(AST.ExpressionList.new(AST.NilLiteralExpression.new(), AST.NilLiteralExpression.new()))
      }, ast)
    end)
  end)
end)
