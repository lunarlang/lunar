local require_dev = require "spec.helpers.require_dev"

describe("Lexer:next_string", function()
  require_dev()

  it("should return a string token whose value is empty", function()
    local tokens = Lexer.new("''"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.string, "''", 1)
    }, tokens)
  end)

  it("should return a string token that has an escaped backslash at the end", function()
    local tokens = Lexer.new("'\\\\'"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.string, "'\\\\'", 1)
    }, tokens)
  end)

  it("should return a string token that has an escaped linefeed at the end", function()
    local tokens = Lexer.new("'\\n'"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.string, "'\\n'", 1)
    }, tokens)
  end)

  it("should return a string token that has an escaped single-quote at the end", function()
    local tokens = Lexer.new("'\\''"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.string, "'\\''", 1)
    }, tokens)
  end)

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
