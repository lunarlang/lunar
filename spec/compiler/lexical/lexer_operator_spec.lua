local Lexer = require "lunar.compiler.lexical.lexer"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer tokenization for operator tokens", function()
  it("should return one triple_dot token", function()
    local tokens = Lexer.new("..."):tokenize()

    assert.same({
      TokenInfo.new(TokenType.triple_dot, "...", 1)
    }, tokens)
  end)

  it("should return one double_equal token", function()
    local tokens = Lexer.new("=="):tokenize()

    assert.same({
      TokenInfo.new(TokenType.double_equal, "==", 1)
    }, tokens)
  end)

  it("should return one tilde_equal token", function()
    local tokens = Lexer.new("~="):tokenize()

    assert.same({
      TokenInfo.new(TokenType.tilde_equal, "~=", 1)
    }, tokens)
  end)

  it("should return one left_angle_equal token", function()
    local tokens = Lexer.new("<="):tokenize()

    assert.same({
      TokenInfo.new(TokenType.left_angle_equal, "<=", 1)
    }, tokens)
  end)

  it("should return one right_angle_equal token", function()
    local tokens = Lexer.new(">="):tokenize()

    assert.same({
      TokenInfo.new(TokenType.right_angle_equal, ">=", 1)
    }, tokens)
  end)

  it("should return one double_dot token", function()
    local tokens = Lexer.new(".."):tokenize()

    assert.same({
      TokenInfo.new(TokenType.double_dot, "..", 1)
    }, tokens)
  end)

  it("should return one left_paren token", function()
    local tokens = Lexer.new("("):tokenize()

    assert.same({
      TokenInfo.new(TokenType.left_paren, "(", 1)
    }, tokens)
  end)

  it("should return one right_paren token", function()
    local tokens = Lexer.new(")"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.right_paren, ")", 1)
    }, tokens)
  end)

  it("should return one left_brace token", function()
    local tokens = Lexer.new("{"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.left_brace, "{", 1)
    }, tokens)
  end)

  it("should return one right_brace token", function()
    local tokens = Lexer.new("}"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.right_brace, "}", 1)
    }, tokens)
  end)

  it("should return one left_bracket token", function()
    local tokens = Lexer.new("["):tokenize()

    assert.same({
      TokenInfo.new(TokenType.left_bracket, "[", 1)
    }, tokens)
  end)

  it("should return one right_bracket token", function()
    local tokens = Lexer.new("]"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.right_bracket, "]", 1)
    }, tokens)
  end)

  it("should return one plus token", function()
    local tokens = Lexer.new("+"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.plus, "+", 1)
    }, tokens)
  end)

  it("should return one minus token", function()
    local tokens = Lexer.new("-"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.minus, "-", 1)
    }, tokens)
  end)

  it("should return one asterisk token", function()
    local tokens = Lexer.new("*"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.asterisk, "*", 1)
    }, tokens)
  end)

  it("should return one slash token", function()
    local tokens = Lexer.new("/"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.slash, "/", 1)
    }, tokens)
  end)

  it("should return one percent token", function()
    local tokens = Lexer.new("%"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.percent, "%", 1)
    }, tokens)
  end)

  it("should return one caret token", function()
    local tokens = Lexer.new("^"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.caret, "^", 1)
    }, tokens)
  end)

  it("should return one pound token", function()
    local tokens = Lexer.new("#"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.pound, "#", 1)
    }, tokens)
  end)

  it("should return one left_angle token", function()
    local tokens = Lexer.new("<"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.left_angle, "<", 1)
    }, tokens)
  end)

  it("should return one right_angle token", function()
    local tokens = Lexer.new(">"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.right_angle, ">", 1)
    }, tokens)
  end)

  it("should return one equal token", function()
    local tokens = Lexer.new("="):tokenize()

    assert.same({
      TokenInfo.new(TokenType.equal, "=", 1)
    }, tokens)
  end)

  it("should return one semi_colon token", function()
    local tokens = Lexer.new(";"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.semi_colon, ";", 1)
    }, tokens)
  end)

  it("should return one colon token", function()
    local tokens = Lexer.new(":"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.colon, ":", 1)
    }, tokens)
  end)

  it("should return one comma token", function()
    local tokens = Lexer.new(","):tokenize()

    assert.same({
      TokenInfo.new(TokenType.comma, ",", 1)
    }, tokens)
  end)

  it("should return one dot token", function()
    local tokens = Lexer.new("."):tokenize()

    assert.same({
      TokenInfo.new(TokenType.dot, ".", 1)
    }, tokens)
  end)
end)
