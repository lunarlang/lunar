local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local BreakStatement = require "lunar.ast.stats.break_statement"
local ReturnStatement = require "lunar.ast.stats.return_statement"
local NilLiteralExpression = require "lunar.ast.exprs.nil_literal_expression"

describe("Parser:parse_last_statement", function()
  describe("BreakStatement syntax", function()
    it("should only return one BreakStatement node", function()
      local tokens = Lexer.new("break"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        BreakStatement.new()
      }, ast)
    end)
  end)

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
end)
