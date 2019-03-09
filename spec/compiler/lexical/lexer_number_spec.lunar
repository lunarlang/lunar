local require_dev = require "spec.helpers.require_dev"

describe("Lexer:next_number", function()
  require_dev()

  local function number_equals(input)
    return function()
      local tokens = Lexer.new(input):tokenize()

      assert.same({
        TokenInfo.new(TokenType.number, input, 1, 1)
      }, tokens)
    end
  end

  it("should return two number tokens", function()
    local tokens = Lexer.new("12 34"):tokenize()

    assert.same({
      TokenInfo.new(TokenType.number, "12", 1, 1),
      TokenInfo.new(TokenType.whitespace_trivia, " ", 1, 3),
      TokenInfo.new(TokenType.number, "34", 1, 4)
    }, tokens)
  end)

  it("should return one number token", number_equals("1234"))

  it("should return one number token given decimal literal is not prefixed with a number", number_equals(".1234"))
  it("should return one number token given decimal literal is prefixed with a number", number_equals("0.1234"))

  it("should return one number token given scientific notation literal", number_equals("1e1"))
  it("should return one number token given scientific notation literal", number_equals("1E1"))
  it("should return one number token given scientific notation literal", number_equals(".1e1"))
  it("should return one number token given scientific notation literal", number_equals("1.e1"))
  it("should return one number token given scientific notation literal", number_equals("1e+1"))
  it("should return one number token given scientific notation literal", number_equals("1e-1"))
  it("should return one number token given scientific notation literal", number_equals("1.1e1"))

  it("should return one number token given hexadecimal literal", number_equals("0x1234567890ABCDEF"))
end)
