local require_dev = require "spec.helpers.require_dev"

describe("WhileStatement syntax", function()
  require_dev()

  it("should only return one WhileStatement node", function()
    local tokens = Lexer.new("while true do end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expr = AST.BooleanLiteralExpression.new(true)

    assert.same({ AST.WhileStatement.new(expr, {}) }, result)
  end)
end)
