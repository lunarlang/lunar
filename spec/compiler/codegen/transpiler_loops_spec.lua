local require_dev = require "spec.helpers.require_dev"

describe("WhileStatement transpilation", function()
  require_dev()

  it("should support while loops calling 'test' 5 times and 'loop_was_ran' 4 times", function()
    local input = "while test() do loop_was_ran() end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local n = 0
    local test = spy.new(function()
      n = n + 1
      return n < 5
    end)
    local loop_was_ran = spy.new(function() end)

    local program = Program.new(result, {
      test = test,
      loop_was_ran = loop_was_ran
    }):run()

    assert.equal(n, 5)
    assert.spy(test).was.called(5)
    assert.spy(loop_was_ran).was.called(4)
  end)

  it("should support break statement to break out of the infinite while loop", function()
    local input = "while true do test() break end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local test = spy.new(function() end)

    local program = Program.new(result, { test = test }):run()

    assert.spy(test).was.called(1)
  end)

  it("should support return statement to return out of the infinite while loop", function()
    local input = "while true do test() return end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local test = spy.new(function() end)

    local program = Program.new(result, { test = test }):run()

    assert.spy(test).was.called(1)
  end)

  it("should support repeat until loops calling 'test' 5 times and 'loop_was_ran' 5 times", function()
    local input = "repeat loop_was_ran() until test()"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local n = 0
    local test = spy.new(function()
      n = n + 1
      return n >= 5
    end)
    local loop_was_ran = spy.new(function() end)

    local program = Program.new(result, {
      test = test,
      loop_was_ran = loop_was_ran
    }):run()

    assert.equal(5, n)
    assert.spy(test).was.called(5)
    assert.spy(loop_was_ran).was.called(5)
  end)
end)
