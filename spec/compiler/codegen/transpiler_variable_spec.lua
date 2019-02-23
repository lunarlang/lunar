local require_dev = require "spec.helpers.require_dev"

describe("Variables transpilation", function()
  require_dev()

  it("should support single variable assignment", function()
    local input = "a = true"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(true, program.env.a)
  end)

  it("should support multiple variables assignment", function()
    local input = "a, b, c = 1, 2, 3"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.env.a)
    assert.equal(2, program.env.b)
    assert.equal(3, program.env.c)
  end)
end)
