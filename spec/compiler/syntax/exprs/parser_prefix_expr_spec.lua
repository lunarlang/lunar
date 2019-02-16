local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("PrefixExpression syntax", function()
  it("should return a BinaryOpExpresssion whose left operand is 1 and right operand is right-associative BinaryOpExpression", function()
    local tokens = Lexer.new("1 + (2 + 3)"):tokenize()
    local ast = Parser.new(tokens):expression()

    local outer_left_operand = AST.NumberLiteralExpression.new(1)
    local inner_left_operand = AST.NumberLiteralExpression.new(2)
    local inner_right_operand = AST.NumberLiteralExpression.new(3)
    local right_operand = AST.BinaryOpExpression.new(inner_left_operand, AST.BinaryOpKind.addition_op, inner_right_operand)

    assert.same(AST.BinaryOpExpression.new(outer_left_operand, AST.BinaryOpKind.addition_op, right_operand), ast)
  end)

  it("should return a MemberExpression named hello", function()
    local tokens = Lexer.new("hello"):tokenize()
    local ast = Parser.new(tokens):expression()

    assert.same(AST.MemberExpression.new(TokenInfo.new(TokenType.identifier, "hello", 1)), ast)
  end)

  it("should return a left MemberExpression named hello with a right MemberExpression named world", function()
    local tokens = Lexer.new("hello.world"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_member = TokenInfo.new(TokenType.identifier, "hello", 1)
    local right_member = TokenInfo.new(TokenType.identifier, "world", 7)

    assert.same(AST.MemberExpression.new(AST.MemberExpression.new(left_member), right_member), ast)
  end)

  it("should return a left MemberExpression named hello with a right MemberExpression of StringLiteralExpression whose value is 'world'", function()
    local tokens = Lexer.new("hello['world']"):tokenize()
    local ast = Parser.new(tokens):expression()

    local left_member = TokenInfo.new(TokenType.identifier, "hello", 1)
    local right_member = AST.StringLiteralExpression.new("'world'")

    assert.same(AST.MemberExpression.new(AST.MemberExpression.new(left_member), right_member), ast)
  end)
end)
