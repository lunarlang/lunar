local require_dev = require "spec.helpers.require_dev"

describe("Lexer:tokenize", function()
  require_dev()

  it("should match with the pattern of a typical local function declaration", function()
    local code = "local function a(b)\n" ..
      "  return b\n" ..
      "end"
    local tokens = Lexer.new(code):tokenize()

    assert.same({
      TokenInfo.new(TokenType.local_keyword, "local", 1, 1),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 1, 6),
      TokenInfo.new(TokenType.function_keyword, "function", 1, 7),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 1, 15),
      TokenInfo.new(TokenType.identifier, "a", 1, 16),
      TokenInfo.new(TokenType.left_paren, "(", 1, 17),
      TokenInfo.new(TokenType.identifier, "b", 1, 18),
      TokenInfo.new(TokenType.right_paren, ")", 1, 19),
      TokenInfo.new(TokenType.end_of_line_trivia, "\n", 1, 20),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 2, 1),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 2, 2),
      TokenInfo.new(TokenType.return_keyword, "return", 2, 3),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 2, 9),
      TokenInfo.new(TokenType.identifier, "b", 2, 10),
      TokenInfo.new(TokenType.end_of_line_trivia, "\n", 2, 11),
      TokenInfo.new(TokenType.end_keyword, "end", 3, 1)
    }, tokens)
  end)
end)
