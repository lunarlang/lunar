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
    local input = "function a.b(c) return c end; return a.b(1), a.b(2)"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local a = {}
    local program = Program.new(result, { a = a }):run()

    assert.equal(1, program.result[1])
    assert.equal(2, program.result[2])
  end)

  it("should support MemberExpression function using colon notation", function()
    local input = "function a:b() return self end; return a:b()"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local a = {}
    local program = Program.new(result, { a = a }):run()

    assert.equal(program.env.a, program.result[1])
  end)

  it("should support varargs", function()
    local input = "function a(...) return {...} end; return a(1, 2), a(4, 'abc', false)"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(2, #program.result[1])
    assert.equal(1, program.result[1][1])
    assert.equal(2, program.result[1][2])

    assert.equal(3, #program.result[2])
    assert.equal(4, program.result[2][1])
    assert.equal("abc", program.result[2][2])
    assert.equal(false, program.result[2][3])
  end)

  it("should support function expressions", function()
    local input = "local a = function(b) return b end; return a(1), a(2)"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1])
    assert.equal(2, program.result[2])
  end)

  it("should support lambda expressions that does not implicitly return", function()
    local input = "return do return 1 end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1]())
  end)

  it("should support lambda expresssions that has parameters and does not implicitly return", function()
    local input = "return |a, b| do return a + b end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(2, program.result[1](1, 1))
    assert.equal(4, program.result[1](1, 3))
  end)

  it("should support lambda expresssions that has parameters and does implicitly return", function()
    local input = "return |a, b| a + b"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(2, program.result[1](1, 1))
    assert.equal(4, program.result[1](1, 3))
  end)

  it("should support lambda expresssions that has no parameters and does implicitly return", function()
    local input = "return || 1"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1]())
    assert.equal(1, program.result[1]())
  end)
end)
