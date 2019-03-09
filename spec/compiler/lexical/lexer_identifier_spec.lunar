local require_dev = require "spec.helpers.require_dev"

describe("Lexer:next_identifier", function()
  require_dev()

  it("should return one identifier token", function()
    local tokens = Lexer.new("look_an_identifier"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.identifier, "look_an_identifier", 1, 1)
    }, tokens)
  end)

  it("should return two identifier tokens with whitespace_trivia inbetween", function()
    local tokens = Lexer.new("id1 id2"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.identifier, "id1", 1, 1),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 1, 4),
      TokenInfo.new(TokenType.identifier, "id2", 1, 5)
    }, tokens)
  end)

  it("should return one identifier token, but starts with a keyword", function()
    local tokens = Lexer.new("dotest"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.identifier, "dotest", 1, 1)
    }, tokens)
  end)
end)
