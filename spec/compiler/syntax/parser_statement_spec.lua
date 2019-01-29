local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("Parser:parse_statement", function()
  describe("DoStatement syntax", function()
    it("should parse one DoStatement node", function()
      local tokens = Lexer.new("do end"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        AST.DoStatement.new()
      }, ast)
    end)

    it("should parse two DoStatement nodes", function()
      local tokens = Lexer.new("do end do end"):tokenize()
      local ast = Parser.new(tokens):parse()

      assert.same({
        AST.DoStatement.new(),
        AST.DoStatement.new()
      }, ast)
    end)

    it("should parse nested DoStatement nodes", function()
      local tokens = Lexer.new("do do do end end end"):tokenize() -- de do do do de da da da
      local ast = Parser.new(tokens):parse()

      assert.same({
        AST.DoStatement.new(AST.DoStatement.new(AST.DoStatement.new()))
      }, ast)
    end)
  end)
end)
