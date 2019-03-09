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

  it("should support self-assigning to a and b with concatenation", function()
    local input = "local a, b = 'hello', 'hi'; a, b ..= ' world', ' there'; return a, b"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal("hello world", program.result[1])
    assert.equal("hi there", program.result[2])
  end)

  it("should support self-assigning to a and b with addition", function()
    local input = "local a, b = 1, 2; a, b += 1, 2; return a, b"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(2, program.result[1])
    assert.equal(4, program.result[2])
  end)

  it("should support self-assigning to a and b with subtraction", function()
    local input = "local a, b = 2, 4; a, b -= 1, 2; return a, b"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1])
    assert.equal(2, program.result[2])
  end)

  it("should support self-assigning to a and b with multiplication", function()
    local input = "local a, b = 1, 2; a, b *= 1, 2; return a, b"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1])
    assert.equal(4, program.result[2])
  end)

  it("should support self-assigning to a and b with division", function()
    local input = "local a, b = 2, 2; a, b /= 1, 2; return a, b"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(2, program.result[1])
    assert.equal(1, program.result[2])
  end)

  it("should support self-assigning to a and b with exponentiation", function()
    local input = "local a, b = 1, 2; a, b ^= 1, 2; return a, b"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1])
    assert.equal(4, program.result[2])
  end)

  it("should support self-assigning with overflowing expressions", function()
    local input = "local a = 1; a += 1, b()"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local b = spy.new(function() end)

    local program = Program.new(result, { b = b }):run()

    assert.spy(b).was.called(1)
  end)

  it("should support self-assigning with overflowing members", function()
    local input = "local a, b = 1, 2; a, b += 1"
    -- would return "a, b = a + 1, b + nil" which throws an error at runtime

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    assert.error(function()
      Program.new(result):run()
    end)
  end)

  it("should support single local variable assignment", function()
    local input = "local a = 1; return a"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1])
  end)

  it("should support multiple local variables assignment", function()
    local input = "local a, b, c = 1, 2, 3; return a, b, c"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1])
    assert.equal(2, program.result[2])
    assert.equal(3, program.result[3])
  end)

  it("should support table literals", function()
    local input = "local a = { 1, ['l o l'] = 2, c = 3 }; return a"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(1, program.result[1][1])
    assert.equal(2, program.result[1]['l o l'])
    assert.equal(3, program.result[1].c)
  end)

  it("should support nil value", function()
    -- we know returning a value works as expected from other cases
    -- but to increase confidence, we'll return 2 as well after the nil value
    local input = "local a = nil; return a, 2"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()

    assert.equal(nil, program.result[1])
    assert.equal(2, program.result[2])
  end)
end)
