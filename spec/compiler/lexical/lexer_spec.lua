local Lexer = require "lunar.compiler.lexical.lexer"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer tokenization for trivial tokens", function()
  it("should return one TokenType.whitespace_trivia", function()
    local tokens = Lexer.new(" "):tokenize()

    assert.same({
      TokenInfo.new(TokenType.whitespace_trivia, " ", 1)
    }, tokens)
  end)
end)
