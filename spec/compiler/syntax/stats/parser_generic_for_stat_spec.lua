local require_dev = require "spec.helpers.require_dev"

describe("GenericForStatement syntax", function()
  require_dev()

  it("should return one GenericForStatement node with one identifier and one expression", function()
    local tokens = Lexer.new("for i in pairs() do end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_identifiers = { AST.Identifier.new("i") }
    local expected_exprlist = {
      AST.FunctionCallExpression.new(AST.Identifier.new("pairs"), {})
    }

    assert.same({
      AST.GenericForStatement.new(expected_identifiers, expected_exprlist, {})
    }, result)
  end)

  it("should return one GenericForStatement node with two identifiers and one expressions", function()
    local tokens = Lexer.new("for i, v in pairs() do end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_identifiers = { AST.Identifier.new("i"), AST.Identifier.new("v") }
    local expected_exprlist = {
      AST.FunctionCallExpression.new(AST.Identifier.new("pairs"), {})
    }

    assert.same({
      AST.GenericForStatement.new(expected_identifiers, expected_exprlist, {})
    }, result)
  end)

  it("should return one GenericForStatement node with two identifiers and two expressions", function()
    local tokens = Lexer.new("for i, v in next, t do end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_identifiers = { AST.Identifier.new("i"), AST.Identifier.new("v") }
    local expected_exprlist = {
      AST.Identifier.new("next"),
      AST.Identifier.new("t")
    }

    assert.same({
      AST.GenericForStatement.new(expected_identifiers, expected_exprlist, {})
    }, result)
  end)
end)
