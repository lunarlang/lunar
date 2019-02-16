local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("BinaryOpExpression syntax", function()
  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is addition_op", function()
    local tokens = Lexer.new("1 + 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.addition_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is subtraction_op", function()
    local tokens = Lexer.new("1 - 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.subtraction_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is multiplication_op", function()
    local tokens = Lexer.new("1 * 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.multiplication_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is division_op", function()
    local tokens = Lexer.new("1 / 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.division_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is modulus_op", function()
    local tokens = Lexer.new("1 % 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.modulus_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is power_op", function()
    local tokens = Lexer.new("1 ^ 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.power_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are StringLiteralExpression and operator is concatenation_op", function()
    local tokens = Lexer.new("'Hello' .. 'world'"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.StringLiteralExpression.new("'Hello'")
    local operator = AST.BinaryOpKind.concatenation_op
    local right_operand = AST.StringLiteralExpression.new("'world'")

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are StringLiteralExpression and operator is not_equal_op", function()
    local tokens = Lexer.new("'Hello' ~= 'world'"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.StringLiteralExpression.new("'Hello'")
    local operator = AST.BinaryOpKind.not_equal_op
    local right_operand = AST.StringLiteralExpression.new("'world'")

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are StringLiteralExpression and operator is equal_op", function()
    local tokens = Lexer.new("'Hello' == 'world'"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.StringLiteralExpression.new("'Hello'")
    local operator = AST.BinaryOpKind.equal_op
    local right_operand = AST.StringLiteralExpression.new("'world'")

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is less_than_op", function()
    local tokens = Lexer.new("1 < 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.less_than_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is less_or_equal_op", function()
    local tokens = Lexer.new("1 <= 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.less_or_equal_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is greater_than_op", function()
    local tokens = Lexer.new("1 > 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.greater_than_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are NumberLiteralExpression and operator is greater_or_equal_op", function()
    local tokens = Lexer.new("1 >= 2"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.NumberLiteralExpression.new(1)
    local operator = AST.BinaryOpKind.greater_or_equal_op
    local right_operand = AST.NumberLiteralExpression.new(2)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are BooleanLiteralExpression and operator is and_op", function()
    local tokens = Lexer.new("true and false"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.BooleanLiteralExpression.new(true)
    local operator = AST.BinaryOpKind.and_op
    local right_operand = AST.BooleanLiteralExpression.new(false)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)

  it("should return a BinaryOpExpression node whose operands are BooleanLiteralExpression and operator is or_op", function()
    local tokens = Lexer.new("false or true"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_operand = AST.BooleanLiteralExpression.new(false)
    local operator = AST.BinaryOpKind.or_op
    local right_operand = AST.BooleanLiteralExpression.new(true)

    assert.same(AST.BinaryOpExpression.new(left_operand, operator, right_operand), ast)
  end)
end)
