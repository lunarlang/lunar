local Lexer = require "lunar.compiler.lexical.lexer"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer tokenization for identifier tokens", function()
  it("should return one TokenType.identifier token", function()
    local tokens = Lexer.new("look_an_identifier"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.identifier, "look_an_identifier", 1)
    }, tokens)
  end)

  it("should return two identifier tokens with whitespace_trivia inbetween", function()
    local tokens = Lexer.new("id1 id2"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.identifier, "id1", 1),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 4),
      TokenInfo.new(TokenType.identifier, "id2", 5)
    }, tokens)
  end)
end)
