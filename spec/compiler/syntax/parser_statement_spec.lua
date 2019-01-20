local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local BreakStatement = require "lunar.ast.stats.break_statement"
local DoStatement = require "lunar.ast.stats.do_statement"
local ReturnStatement = require "lunar.ast.stats.return_statement"
local NilLiteralExpression = require "lunar.ast.exprs.nil_literal_expression"

describe("Parser:parse_statement", function()
  describe("BreakStatement syntax", function()
    it("should only return one BreakStatement node", function()
      local tokens = Lexer.new("break"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        BreakStatement.new()
      }, ast)
    end)
  end)

  describe("DoStatement syntax", function()
    it("should parse one DoStatement node", function()
      local tokens = Lexer.new("do end"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        DoStatement.new()
      }, ast)
    end)

    it("should parse two DoStatement nodes", function()
      local tokens = Lexer.new("do end do end"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        DoStatement.new(),
        DoStatement.new()
      }, ast)
    end)

    it("should parse nested DoStatement nodes", function()
      local tokens = Lexer.new("do do do end end end"):tokenize() -- de do do do de da da da
      local ast = Parser.new(tokens):parse()

      assert.same({
        DoStatement.new(DoStatement.new(DoStatement.new()))
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
