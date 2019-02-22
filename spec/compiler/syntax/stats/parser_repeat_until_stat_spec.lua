local require_dev = require "spec.helpers.require_dev"

describe("RepeatUntilStatement syntax", function()
  require_dev()

  it("should only return one RepeatUntilStatement node", function()
    local tokens = Lexer.new("repeat until true"):tokenize()
    local result = Parser.new(tokens):parse()

    local expr = AST.BooleanLiteralExpression.new(true)

    assert.same({ AST.RepeatUntilStatement.new({}, expr) }, result)
  end)
end)
