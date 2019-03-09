local require_dev = require "spec.helpers.require_dev"

describe("RangeForStatement syntax", function()
  require_dev()

  it("should return one RangeForStatement node with two expressions", function()
    local tokens = Lexer.new("for i = 1, 2 do end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.RangeForStatement.new(
        AST.Identifier.new("i"),
        AST.NumberLiteralExpression.new(1),
        AST.NumberLiteralExpression.new(2),
        nil,
        {}
      )
    }, result)
  end)

  it("should return one RangeForStatement node with three expressions", function()
    local tokens = Lexer.new("for i = 1, 2, 3 do end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.RangeForStatement.new(
        AST.Identifier.new("i"),
        AST.NumberLiteralExpression.new(1),
        AST.NumberLiteralExpression.new(2),
        AST.NumberLiteralExpression.new(3),
        {}
      )
    }, result)
  end)
end)
