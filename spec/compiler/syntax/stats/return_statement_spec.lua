local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local ReturnStatement = require "lunar.ast.stats.return_statement"

describe("ReturnStatement syntax", function()
  it("should only return one ReturnStatement node", function()
    local tokens = Lexer.new("return"):tokenize()
    local ast = Parser.new(tokens):parse()

    assert.same({
      ReturnStatement.new()
    }, ast)
  end)

  pending("should return one ReturnStatement node with one expression")

  pending("should return one ReturnStatement node with two expressions")
end)
