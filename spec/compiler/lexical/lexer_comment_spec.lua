local Lexer = require "lunar.compiler.lexical.lexer"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer:next_comment", function()
  it("should return one comment token", function()
    local tokens = Lexer.new("-- Hello, world!"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.comment, "-- Hello, world!", 1)
    }, tokens)
  end)

  it("should return one comment token with many comment signs in a single line", function()
    local tokens = Lexer.new("---- Hello, world! ----"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.comment, "---- Hello, world! ----", 1)
    }, tokens)
  end)

  it("should return one comment token with nothing immediately followed", function()
    local tokens = Lexer.new("--"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.comment, "--", 1)
    }, tokens)
  end)

  it("should return two comment tokens", function()
    local code = "-- first comment\n" ..
      "-- second comment"
    local tokens = Lexer.new(code):tokenize()

    assert.same({
      TokenInfo.new(TokenType.comment, "-- first comment", 1),
      TokenInfo.new(TokenType.end_of_line_trivia, "\n", 17),
      TokenInfo.new(TokenType.comment, "-- second comment", 18)
    }, tokens)
  end)

  it("should return one multiline comment token", function()
    local tokens = Lexer.new("--[[ Hello, world! ]]"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.comment, "--[[ Hello, world! ]]", 1)
    }, tokens)
  end)

  it("should not span multiple lines if there is anything between -- and the block", function()
    local code = "-- [=[ Hello, world! ]=]\n" ..
      "nope"
    local tokens = Lexer.new(code):tokenize()

    assert.same({
      TokenInfo.new(TokenType.comment, "-- [=[ Hello, world! ]=]", 1),
      TokenInfo.new(TokenType.end_of_line_trivia, "\n", 25),
      TokenInfo.new(TokenType.identifier, "nope", 26)
    }, tokens)
  end)
end)
