local Lexer = require "lunar.compiler.lexical.lexer"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer", function()
  it("should return one TokenType.whitespace_trivia", function()
    local tokens = Lexer.new(" "):tokenize()

    assert.equal(1, #tokens)
    assert.equal(TokenType.whitespace_trivia, tokens[1].token_type)
  end)
end)
