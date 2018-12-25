local Lexer = require "lunar.compiler.lexical.lexer"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer:tokenize", function()
  it("should match with the pattern of a typical local function declaration", function()
    local code = "local function a(b)\n" ..
      "  return b\n" ..
      "end"
    local tokens = Lexer.new(code):tokenize()

    assert.same({
      TokenInfo.new(TokenType.local_keyword, "local", 1),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 6),
      TokenInfo.new(TokenType.function_keyword, "function", 7),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 15),
      TokenInfo.new(TokenType.identifier, "a", 16),
      TokenInfo.new(TokenType.left_paren, "(", 17),
      TokenInfo.new(TokenType.identifier, "b", 18),
      TokenInfo.new(TokenType.right_paren, ")", 19),
      TokenInfo.new(TokenType.end_of_line_trivia, "\n", 20),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 21),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 22),
      TokenInfo.new(TokenType.return_keyword, "return", 23),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 29),
      TokenInfo.new(TokenType.identifier, "b", 30),
      TokenInfo.new(TokenType.end_of_line_trivia, "\n", 31),
      TokenInfo.new(TokenType.end_keyword, "end", 32)
    }, tokens)
  end)
end)
