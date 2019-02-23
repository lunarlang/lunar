local require_dev = require "spec.helpers.require_dev"
-- setup handler is called too late, so we need to require this early
local TokenType = require "lunar.compiler.lexical.token_type"

describe("Lexer:next_operator", function()
  require_dev()

  local function operator_equals(op, token_type)
    return function()
      local tokens = Lexer.new(op):tokenize()

      assert.same({
        TokenInfo.new(token_type, op, 1)
      }, tokens)
    end
  end

  it("should return one triple_dot token", operator_equals("...", TokenType.triple_dot))
  it("should return one double_dot_equal token", operator_equals("..=", TokenType.double_dot_equal))

  it("should return one double_equal token", operator_equals("==", TokenType.double_equal))
  it("should return one tilde_equal token", operator_equals("~=", TokenType.tilde_equal))
  it("should return one left_angle_equal token", operator_equals("<=", TokenType.left_angle_equal))
  it("should return one right_angle_equal token", operator_equals(">=", TokenType.right_angle_equal))
  it("should return one double_dot token", operator_equals("..", TokenType.double_dot))
  it("should return one plus_equal token", operator_equals("+=", TokenType.plus_equal))
  it("should return one minus_equal token", operator_equals("-=", TokenType.minus_equal))
  it("should return one asterisk_equal token", operator_equals("*=", TokenType.asterisk_equal))
  it("should return one slash_equal token", operator_equals("/=", TokenType.slash_equal))
  it("should return one caret_equal token", operator_equals("^=", TokenType.caret_equal))

  it("should return one left_paren token", operator_equals("(", TokenType.left_paren))
  it("should return one right_paren token", operator_equals(")", TokenType.right_paren))
  it("should return one left_brace token", operator_equals("{", TokenType.left_brace))
  it("should return one right_brace token", operator_equals("}", TokenType.right_brace))
  it("should return one left_bracket token", operator_equals("[", TokenType.left_bracket))
  it("should return one right_bracket token", operator_equals("]", TokenType.right_bracket))
  it("should return one plus token", operator_equals("+", TokenType.plus))
  it("should return one minus token", operator_equals("-", TokenType.minus))
  it("should return one asterisk token", operator_equals("*", TokenType.asterisk))
  it("should return one slash token", operator_equals("/", TokenType.slash))
  it("should return one percent token", operator_equals("%", TokenType.percent))
  it("should return one caret token", operator_equals("^", TokenType.caret))
  it("should return one pound token", operator_equals("#", TokenType.pound))
  it("should return one left_angle token", operator_equals("<", TokenType.left_angle))
  it("should return one right_angle token", operator_equals(">", TokenType.right_angle))
  it("should return one equal token", operator_equals("=", TokenType.equal))
  it("should return one semi_colon token", operator_equals(";", TokenType.semi_colon))
  it("should return one colon token", operator_equals(":", TokenType.colon))
  it("should return one comma token", operator_equals(",", TokenType.comma))
  it("should return one dot token", operator_equals(".", TokenType.dot))
  it("should return one bar token", operator_equals("|", TokenType.bar))
end)
