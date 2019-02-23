local require_dev = require "spec.helpers.require_dev"

describe("WhileStatement transpilation", function()
  require_dev()

  it("should support calling a function with no arguments", function()
    local input = "hello()"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local hello = spy.new(function() end)

    local program = Program.new(result, { hello = hello }):run()

    assert.spy(hello).was.called()
  end)

  it("should support calling a function using dot notation with a string argument", function()
    local input = "hello.world('cool stuff')"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local hello = {}
    hello.world = spy.new(function() end)

    local program = Program.new(result, { hello = hello }):run()

    assert.spy(hello.world).was.called()
    assert.spy(hello.world).was.called_with("cool stuff")
  end)

  it("should support calling a function using colon notation with self and boolean arguments", function()
    local input = "hello:world(true)"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local hello = {}
    hello.world = spy.new(function() end)

    local program = Program.new(result, { hello = hello }):run()

    assert.spy(hello.world).was.called()
    assert.spy(hello.world).was.called_with(hello, true)
  end)

  it("should support calling a function using bracket notation with a number argument", function()
    local input = "hello['world'](1)"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local hello = {}
    hello['world'] = spy.new(function() end)

    local program = Program.new(result, { hello = hello }):run()

    assert.spy(hello['world']).was.called()
    assert.spy(hello['world']).was.called_with(1)
  end)
end)
