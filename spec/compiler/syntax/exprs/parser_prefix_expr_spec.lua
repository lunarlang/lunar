local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("PrefixExpression syntax", function()
  it("should return a BinaryOpExpression whose left operand is 1 and right operand is right-associative BinaryOpExpression", function()
    local tokens = Lexer.new("1 + (2 + 3)"):tokenize()
    local result = Parser.new(tokens):expression()

    local outer_left_operand = AST.NumberLiteralExpression.new(1)
    local inner_left_operand = AST.NumberLiteralExpression.new(2)
    local inner_right_operand = AST.NumberLiteralExpression.new(3)
    local right_operand = AST.BinaryOpExpression.new(inner_left_operand, AST.BinaryOpKind.addition_op, inner_right_operand)

    assert.same(AST.BinaryOpExpression.new(outer_left_operand, AST.BinaryOpKind.addition_op, right_operand), result)
  end)

  it("should return a MemberExpression named hello", function()
    local tokens = Lexer.new("hello"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.MemberExpression.new("hello"), result)
  end)

  it("should return a left MemberExpression named hello with a right MemberExpression named world", function()
    local tokens = Lexer.new("hello.world"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.MemberExpression.new(AST.MemberExpression.new("hello"), "world"), result)
  end)

  it("should return a left MemberExpression named hello with a right MemberExpression of StringLiteralExpression whose value is 'world'", function()
    local tokens = Lexer.new("hello['world']"):tokenize()
    local result = Parser.new(tokens):expression()

    local right_member = AST.StringLiteralExpression.new("'world'")

    assert.same(AST.MemberExpression.new(AST.MemberExpression.new("hello"), right_member), result)
  end)
end)
