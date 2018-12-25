local Lexer = require "lunar.compiler.lexical.lexer"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer:next_keyword", function()
  it("should return one and_keyword token", function()
    local tokens = Lexer.new("and"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.and_keyword, "and", 1)
    }, tokens)
  end)

  it("should return one break_keyword token", function()
    local tokens = Lexer.new("break"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.break_keyword, "break", 1)
    }, tokens)
  end)

  it("should return one do_keyword token", function()
    local tokens = Lexer.new("do"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.do_keyword, "do", 1)
    }, tokens)
  end)

  it("should return one elseif_keyword token", function()
    local tokens = Lexer.new("elseif"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.elseif_keyword, "elseif", 1)
    }, tokens)
  end)

  it("should return one else_keyword token", function()
    local tokens = Lexer.new("else"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.else_keyword, "else", 1)
    }, tokens)
  end)

  it("should return one end_keyword token", function()
    local tokens = Lexer.new("end"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.end_keyword, "end", 1)
    }, tokens)
  end)

  it("should return one false_keyword token", function()
    local tokens = Lexer.new("false"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.false_keyword, "false", 1)
    }, tokens)
  end)

  it("should return one for_keyword token", function()
    local tokens = Lexer.new("for"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.for_keyword, "for", 1)
    }, tokens)
  end)

  it("should return one function_keyword token", function()
    local tokens = Lexer.new("function"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.function_keyword, "function", 1)
    }, tokens)
  end)

  it("should return one if_keyword token", function()
    local tokens = Lexer.new("if"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.if_keyword, "if", 1)
    }, tokens)
  end)

  it("should return one in_keyword token", function()
    local tokens = Lexer.new("in"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.in_keyword, "in", 1)
    }, tokens)
  end)

  it("should return one local_keyword token", function()
    local tokens = Lexer.new("local"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.local_keyword, "local", 1)
    }, tokens)
  end)

  it("should return one nil_keyword token", function()
    local tokens = Lexer.new("nil"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.nil_keyword, "nil", 1)
    }, tokens)
  end)

  it("should return one not_keyword token", function()
    local tokens = Lexer.new("not"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.not_keyword, "not", 1)
    }, tokens)
  end)

  it("should return one or_keyword token", function()
    local tokens = Lexer.new("or"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.or_keyword, "or", 1)
    }, tokens)
  end)

  it("should return one repeat_keyword token", function()
    local tokens = Lexer.new("repeat"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.repeat_keyword, "repeat", 1)
    }, tokens)
  end)

  it("should return one return_keyword token", function()
    local tokens = Lexer.new("return"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.return_keyword, "return", 1)
    }, tokens)
  end)

  it("should return one then_keyword token", function()
    local tokens = Lexer.new("then"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.then_keyword, "then", 1)
    }, tokens)
  end)

  it("should return one true_keyword token", function()
    local tokens = Lexer.new("true"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.true_keyword, "true", 1)
    }, tokens)
  end)

  it("should return one until_keyword token", function()
    local tokens = Lexer.new("until"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.until_keyword, "until", 1)
    }, tokens)
  end)

  it("should return one while_keyword token", function()
    local tokens = Lexer.new("while"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.while_keyword, "while", 1)
    }, tokens)
  end)
end)
