local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local BreakStatement = require "lunar.ast.stats.break_statement"

describe("BreakStatement syntax", function()
  it("should only return one BreakStatement node", function()
    local tokens = Lexer.new("break"):tokenize()
    local ast = Parser.new(tokens):parse()

    assert.same({
      BreakStatement.new()
    }, ast)
  end)
end)
