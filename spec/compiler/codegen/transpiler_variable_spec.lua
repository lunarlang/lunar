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
