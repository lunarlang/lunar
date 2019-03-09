local require_dev = require "spec.helpers.require_dev"

describe("VariableStatement syntax", function()
  require_dev()

  it("should return one VariableSyntax node with two names and two expressions", function()
    local tokens = Lexer.new("local a, b = 1, 2"):tokenize()
    local result = Parser.new(tokens):parse()

    local names = { AST.Identifier.new("a"), AST.Identifier.new("b") }
    local exprs = {
      AST.NumberLiteralExpression.new(1),
      AST.NumberLiteralExpression.new(2)
    }

    assert.same({ AST.VariableStatement.new(names, exprs) }, result)
  end)

  it("should return one VariableSyntax node with two names and one expression", function()
    local tokens = Lexer.new("local a, b = ..."):tokenize()
    local result = Parser.new(tokens):parse()

    local names = { AST.Identifier.new("a"), AST.Identifier.new("b") }
    local exprs = { AST.VariableArgumentExpression.new() }

    assert.same({ AST.VariableStatement.new(names, exprs) }, result)
  end)

  it("should return one VariableSyntax node with one name and no expression", function()
    local tokens = Lexer.new("local a"):tokenize()
    local result = Parser.new(tokens):parse()

    local names = { AST.Identifier.new("a") }

    assert.same({ AST.VariableStatement.new(names, nil) }, result)
  end)

  it("should return two VariableSyntax node with one name and one expression, each", function()
    local tokens = Lexer.new("local a = 1 local b = 2"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.VariableStatement.new({ AST.Identifier.new("a") }, { AST.NumberLiteralExpression.new(1) }),
      AST.VariableStatement.new({ AST.Identifier.new("b") }, { AST.NumberLiteralExpression.new(2) })
    }, result)
  end)

  it("should attach type annotations in a number dictionary", function()
    local tokens = Lexer.new("local a: string, b, c: any = 1, 2, 3"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.VariableStatement.new(
        { AST.Identifier.new("a", AST.Identifier.new("string")), AST.Identifier.new("b"), AST.Identifier.new("c", AST.Identifier.new("any")) },
        { AST.NumberLiteralExpression.new(1), AST.NumberLiteralExpression.new(2), AST.NumberLiteralExpression.new(3) }),
    }, result)
  end)

  it("should attach a type annotation in a statement with one name and no expression", function()
    local tokens = Lexer.new("local a: string"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.VariableStatement.new({ AST.Identifier.new("a", AST.Identifier.new("string")) }),
    }, result)
  end)
end)
