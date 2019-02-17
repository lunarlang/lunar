local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("RepeatUntilStatement syntax", function()
  it("should only return one RepeatUntilStatement node", function()
    local tokens = Lexer.new("repeat until true"):tokenize()
    local result = Parser.new(tokens):parse()

    local expr = AST.BooleanLiteralExpression.new(true)

    assert.same({ AST.RepeatUntilStatement.new({}, expr) }, result)
  end)
end)
