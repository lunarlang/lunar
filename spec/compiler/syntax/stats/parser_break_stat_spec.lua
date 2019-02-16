local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("BreakStatement syntax", function()
  it("should only return one BreakStatement node", function()
    local tokens = Lexer.new("break"):tokenize()
    local ast = Parser.new(tokens):parse()

    assert.same({
      AST.BreakStatement.new()
    }, ast)
  end)
end)
