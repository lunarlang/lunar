local require_dev = require "spec.helpers.require_dev"

describe("BinaryOp expressions transpilation", function()
  require_dev()

  local function binary_op_equals(input, expected)
    return function()
      local tokens = Lexer.new("return " .. input):tokenize()
      local ast = Parser.new(tokens):parse()
      local result = Transpiler.new(ast):transpile()

      local program = Program.new(result):run()

      assert.equal(expected, program.result[1])
    end
  end

  it("should support one addition_op BinaryOpExpression", binary_op_equals("1 + 1", 2))
  it("should support two addition_op BinaryOpExpression", binary_op_equals("1 + 1 + 1", 3))

  it("should support one subtraction_op BinaryOpExpression", binary_op_equals("2 - 1", 1))
  it("should support two subtraction_op BinaryOpExpression", binary_op_equals("3 - 2 - 1", 0))
  it("should support parenthesized BinaryOpExpression", binary_op_equals("3 - (2 - 1)", 2))

  it("should support one multiplication_op BinaryOpExpression", binary_op_equals("1 * 2", 2))
  it("should support two multiplication_op BinaryOpExpression", binary_op_equals("1 * 2 * 3", 6))

  it("should support one division_op BinaryOpExpression", binary_op_equals("2 / 1", 2))
  it("should support two division_op BinaryOpExpression", binary_op_equals("6 / 3 / 1", 2))

  it("should support one modulus_op BinaryOpExpression", binary_op_equals("2 % 2", 0))
  it("should support two modulus_op BinaryOpExpression", binary_op_equals("1 % 2 % 3", 1))

  it("should support one power_op BinaryOpExpression", binary_op_equals("1 ^ 2", 1))
  it("should support two power_op BinaryOpExpression", binary_op_equals("1 ^ 2 ^ 3", 1))

  it("should support one concatenation_op BinaryOpExpression", binary_op_equals("'a' .. 'b'", "ab"))
  it("should support two concatenation_op BinaryOpExpression", binary_op_equals("'a' .. 'b' .. 'c'", "abc"))

  it("should support one not_equal_op BinaryOpExpression", binary_op_equals("true ~= true", false))
  it("should support two not_equal_op BinaryOpExpression", binary_op_equals("true ~= true ~= true", true))

  it("should support one equal_op BinaryOpExpression", binary_op_equals("true == true", true))
  it("should support two equal_op BinaryOpExpression", binary_op_equals("true == true == true", true))

  it("should support one less_than_op BinaryOpExpression", binary_op_equals("1 < 2", true))
  it("should support one less_or_equal_op BinaryOpExpression", binary_op_equals("1 <= 2", true))
  it("should support one greater_than_op BinaryOpExpression", binary_op_equals("2 > 1", true))
  it("should support one greater_or_equal_op BinaryOpExpression", binary_op_equals("2 >= 1", true))

  it("should support nested BinaryOpExpression", binary_op_equals("1 == 1 and 2 == 2 or 3", true))
  it("should support one and_op BinaryOpExpression", binary_op_equals("1 and 2", 2))
  it("should support one or_op BinaryOpExpression", binary_op_equals("1 or 2", 1))
end)
