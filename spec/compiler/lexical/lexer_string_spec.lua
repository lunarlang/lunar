local Lexer = require "lunar.compiler.lexical.lexer"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer:next_string", function()
  it("should return a string token using single quotes", function()
    local tokens = Lexer.new("'Hello, world!'"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.string, "'Hello, world!'", 1)
    }, tokens)
  end)

  it("should return a string token using double quotes", function()
    local tokens = Lexer.new("\"Hello, world!\""):tokenize()

    assert.same({
      TokenInfo.new(TokenType.string, "\"Hello, world!\"", 1)
    }, tokens)
  end)

  it("should return a string token using multiline block", function()
    local tokens = Lexer.new("[[ Hello, world! ]]"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.string, "[[ Hello, world! ]]", 1)
    }, tokens)
  end)

  it("should return a string token using leveled multiline block", function()
    local tokens = Lexer.new("[====[ Hello, world! ]====]"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.string, "[====[ Hello, world! ]====]", 1)
    }, tokens)
  end)

  it("should throw an error when encountering a newline while scanning", function()
    assert.has_error(function()
      Lexer.new("'abc\n'"):tokenize()
    end, "unfinished string near ''abc'")
  end)

  it("should throw an error when encountering end of file while scanning", function()
    assert.has_error(function()
      Lexer.new("'abc"):tokenize()
    end, "unfinished string near <eof>")
  end)

  it("should throw an error when encountering end of file while scanning multiline block", function()
    assert.has_error(function()
      Lexer.new("[[abc"):tokenize()
    end, "unfinished string near <eof>")
  end)

  it("should not return a string token from invalid multiline block syntax", function()
    local tokens = Lexer.new("[ =[ Hello, world ]]"):tokenize()

    assert.is_not.same({
      TokenInfo.new(TokenType.string, "[ =[ Hello, world ]]", 1)
    }, tokens)
  end)
end)
