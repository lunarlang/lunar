local require_dev = require "spec.helpers.require_dev"

describe("UnaryOp expressions transpilation", function()
  require_dev()

  local function unary_op_equals(input, expected)
    return function()
      local tokens = Lexer.new("return " .. input):tokenize()
      local ast = Parser.new(tokens):parse()
      local result = Transpiler.new(ast):transpile()

      local program = Program.new(result):run()

      assert.equal(expected, program.result[1])
    end
  end

  it("should support one negative_op UnaryOpKind", unary_op_equals("-1", -1))
  it("should support two negative_op UnaryOpKind", unary_op_equals("- -1", 1))

  it("should support one not_op UnaryOpKind", unary_op_equals("not true", false)) -- this expression is not true
  it("should support two not_op UnaryOpKind", unary_op_equals("not not true", true))

  it("should support one length_op UnaryOpKind", unary_op_equals("#{ 1, 2 }", 2))
end)
