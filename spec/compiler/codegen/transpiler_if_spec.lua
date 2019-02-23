local require_dev = require "spec.helpers.require_dev"

describe("IfStatement transpilation", function()
  require_dev()

  it("should call hello in the first if branch", function()
    local input = "if true then hello() end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local hello = spy.new(function() end)

    local program = Program.new(result, { hello = hello }):run()

    assert.spy(hello).was.called()
  end)

  it("should call hello2 in the elseif branch", function()
    local input = "if false then hello() elseif true then hello2() end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local hello = spy.new(function() end)
    local hello2 = spy.new(function() end)

    local program = Program.new(result, {
      hello = hello,
      hello2 = hello2
    }):run()

    assert.spy(hello).was_not.called()
    assert.spy(hello2).was.called()
  end)

  it("should call hello3 in the else branch", function()
    local input = "if false then hello() elseif false then hello2() else hello3() end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local hello = spy.new(function() end)
    local hello2 = spy.new(function() end)
    local hello3 = spy.new(function() end)

    local program = Program.new(result, {
      hello = hello,
      hello2 = hello2,
      hello3 = hello3
    }):run()

    assert.spy(hello).was_not.called()
    assert.spy(hello2).was_not.called()
    assert.spy(hello3).was.called()
  end)
end)
