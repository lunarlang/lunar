local require_dev = require "spec.helpers.require_dev"

describe("AssignmentStatement syntax", function()
  require_dev()

  it("should return one AssignmentStatement with one Identifier and one expression", function()
    local tokens = Lexer.new("hello = 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.Identifier.new("hello") }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement with one MemberExpression using bracket notation and one expression", function()
    local tokens = Lexer.new("hello['world'] = 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.MemberExpression.new(AST.Identifier.new("hello"), AST.StringLiteralExpression.new("'world'")) }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement with one MemberExpression using dot notation and one expression", function()
    local tokens = Lexer.new("hello.world = 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.MemberExpression.new(AST.Identifier.new("hello"), AST.Identifier.new("world")) }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement with two Identifiers and one expression", function()
    local tokens = Lexer.new("hello, world = ..."):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.Identifier.new("hello"), AST.Identifier.new("world") }
    local exprs = { AST.VariableArgumentExpression.new() }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement whose operator is concatenation_equal_op", function()
    local tokens = Lexer.new("hello ..= 'world'"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.Identifier.new("hello") }
    local exprs = { AST.StringLiteralExpression.new("'world'") }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.concatenation_equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement whose operator is addition_equal_op", function()
    local tokens = Lexer.new("hello += 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.Identifier.new("hello") }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.addition_equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement whose operator is subtraction_equal_op", function()
    local tokens = Lexer.new("hello -= 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.Identifier.new("hello") }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.subtraction_equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement whose operator is multiplication_equal_op", function()
    local tokens = Lexer.new("hello *= 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.Identifier.new("hello") }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.multiplication_equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement whose operator is division_equal_op", function()
    local tokens = Lexer.new("hello /= 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.Identifier.new("hello") }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.division_equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement whose operator is power_equal_op", function()
    local tokens = Lexer.new("hello ^= 1"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.Identifier.new("hello") }
    local exprs = { AST.NumberLiteralExpression.new(1) }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.power_equal_op, exprs) }, result)
  end)

  it("should return one AssignmentStatement with one identifier and two expressions with concatenation_equal_op", function()
    local tokens = Lexer.new("hello ..= 'world', a()"):tokenize()
    local result = Parser.new(tokens):parse()

    local variables = { AST.Identifier.new("hello") }
    local exprs = {
      AST.StringLiteralExpression.new("'world'"),
      AST.FunctionCallExpression.new(AST.Identifier.new("a"), {})
    }

    assert.same({ AST.AssignmentStatement.new(variables, AST.SelfAssignmentOpKind.concatenation_equal_op, exprs) }, result)
  end)

  it("should throw an error given an invalid left-hand side identifier", function()
    local tokens = Lexer.new("hi() = 1"):tokenize()

    local parse = function()
      Parser.new(tokens):parse()
    end

    assert.errors(parse, "Unexpected token '=' at 6")
  end)
end)
