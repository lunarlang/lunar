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

  it("should support varargs", function()
    local input = "function a(...) return ... end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()
    spy.on(program.env, "a")

    local r = { program.env.a(1, 2) }
    assert.spy(program.env.a).was.called_with(1, 2)
    assert.equal(2, #r)
    assert.equal(1, r[1])
    assert.equal(2, r[2])

    local r = { program.env.a(4, "abc", false) }
    assert.spy(program.env.a).was.called_with(4, "abc", false)
    assert.equal(3, #r)
    assert.equal(4, r[1])
    assert.equal("abc", r[2])
    assert.equal(false, r[3])
  end)
end)
