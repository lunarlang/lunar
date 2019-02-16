local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("WhileStatement syntax", function()
  it("should only return one WhileStatement node", function()
    local tokens = Lexer.new("while true do end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expr = AST.BooleanLiteralExpression.new(true)

    assert.same({ AST.WhileStatement.new(expr, {}) }, result)
  end)
end)
