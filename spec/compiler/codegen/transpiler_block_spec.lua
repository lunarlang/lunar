local require_dev = require "spec.helpers.require_dev"

describe("Block transpilation", function()
  require_dev()

  it("should call test and return two expressions", function()
    local input = "test() return 1, false"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local test = spy.new(function() end)

    local program = Program.new(result, { test = test }):run()

    assert.spy(test).was.called(1)
    assert.equal(1, program.result[1])
    assert.equal(false, program.result[2])
  end)

  it("should support do end block calling test", function()
    local input = "do test() end"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local test = spy.new(function() end)

    Program.new(result, { test = test }):run()

    assert.spy(test).was.called(1)
  end)

  it("should support shadowing of local variables", function()
    local input = "local a = 1\n" ..
      "do local a = 2 end\n" ..
      "return a"

      local tokens = Lexer.new(input):tokenize()
      local ast = Parser.new(tokens):parse()
      local result = Transpiler.new(ast):transpile()

      local program = Program.new(result):run()

      assert.equal(1, program.result[1])
  end)
end)
