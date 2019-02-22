local require_dev = require "spec.helpers.require_dev"

describe("BreakStatement syntax", function()
  require_dev()

  it("should only return one BreakStatement node", function()
    local tokens = Lexer.new("break"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({ AST.BreakStatement.new() }, result)
  end)
end)
