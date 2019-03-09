local require_dev = require "spec.helpers.require_dev"

describe("ClassStatement transpilation", function()
  require_dev()

  it("should support classes with no members", function()
    local input = "class C end; return C"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()
    local C = program.result[1]

    assert.same({}, C.new())
  end)

  it("should support field members in a class", function()
    local input = "class C static x = 'hello' x = 'world' end; return C"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()
    local C = program.result[1]

    assert.equal("hello", C.x)
    assert.equal("world", C.new().x)
  end)

  it("should support parameterized constructor", function()
    local input = "class C\n" ..
      "constructor(message) self.message = message end\n" ..
      "end\n" ..
      "return C"

      local tokens = Lexer.new(input):tokenize()
      local ast = Parser.new(tokens):parse()
      local result = Transpiler.new(ast):transpile()

      local program = Program.new(result):run()
      local C = program.result[1]

      assert.same({ message = "hello" }, C.new("hello"))
  end)

  it("should support separation of static methods from instance methods", function()
    local input = "class C\n" ..
      "static function m() return 'hi' end\n" ..
      "function m() return 'hello' end\n" ..
      "end\n" ..
      "return C"

      local tokens = Lexer.new(input):tokenize()
      local ast = Parser.new(tokens):parse()
      local result = Transpiler.new(ast):transpile()

      local program = Program.new(result):run()
      local C = program.result[1]

      assert.same("hi", C.m())
      assert.same("hello", C.new():m())
  end)

  it("should support instance methods", function()
    local input = "class C\n" ..
      "constructor(name) self.name = name end\n" ..
      "function get_name() return self.name end\n" ..
      "end\n" ..
      "return C"

      local tokens = Lexer.new(input):tokenize()
      local ast = Parser.new(tokens):parse()
      local result = Transpiler.new(ast):transpile()

      local program = Program.new(result):run()
      local C = program.result[1]

      assert.same("test", C.new("test"):get_name())
  end)

  it("should support inheritance with super call", function()
    local input = "class S\n" ..
      "constructor(name) self.name = name end\n" ..
      "end\n" ..
      "class C << S\n" ..
      "constructor() super('bob') end\n" ..
      "end\n" ..
      "return C"

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()
    local C = program.result[1]

    assert.same("bob", C.new().name)
  end)

  it("should inherit fields and methods from the super class for static and instance members", function()
    local input = [[
class S
  static f = 'sf';
  f = 'if';

  static function m() return 'sm' end;
  function m() return 'im' end;
end

class C << S
  constructor()
    super()
  end
end

return C]]

    local tokens = Lexer.new(input):tokenize()
    local ast = Parser.new(tokens):parse()
    local result = Transpiler.new(ast):transpile()

    local program = Program.new(result):run()
    local C = program.result[1]

    assert.equal("sf", C.f)
    assert.equal("sm", C.m())
    assert.equal("if", C.new().f)
    assert.equal("im", C.new():m())
  end)
end)
