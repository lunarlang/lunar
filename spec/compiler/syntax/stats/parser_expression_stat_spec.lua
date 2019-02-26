local require_dev = require "spec.helpers.require_dev"

describe("ExpressionStatement syntax", function()
  require_dev()

  it("should return one ExpressionStatement node with an expression of FunctionCallExpression", function()
    local tokens = Lexer.new("hello()"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.ExpressionStatement.new(AST.FunctionCallExpression.new(AST.Identifier.new("hello"), {}))
    }, result)
  end)
end)
