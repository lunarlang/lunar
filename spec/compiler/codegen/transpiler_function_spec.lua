local require_dev = require "spec.helpers.require_dev"

describe("FunctionStatement transpilation", function()
  require_dev()

  it("should support local function with one parameter", function()
    local input = "local function hello(a) return a end; return hello(1), hello(2)"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1])
    assert.equal(2, program.result[2])
  end)

  it("should support MemberExpression function using dot notation", function()
    local input = "function a.b(c) return c end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local a = {}
    local program = Program.new(result, { a = a }):run()

    assert.equal(1, program.env.a.b(1))
    assert.equal(2, program.env.a.b(2))
  end)

  it("should support MemberExpression function using colon notation", function()
    local input = "function a:b() return self end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local a = {}
    local program = Program.new(result, { a = a }):run()

    assert.equal(program.env.a, program.env.a:b())
  end)
end)
