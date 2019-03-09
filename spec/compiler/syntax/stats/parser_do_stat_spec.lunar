local require_dev = require "spec.helpers.require_dev"

describe("DoStatement syntax", function()
  require_dev()

  it("should parse one DoStatement node", function()
    local tokens = Lexer.new("do end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({ AST.DoStatement.new({}) }, result)
  end)

  it("should parse two DoStatement nodes", function()
    local tokens = Lexer.new("do end do end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({ AST.DoStatement.new({}), AST.DoStatement.new({}) }, result)
  end)

  it("should parse nested DoStatement nodes", function()
    local tokens = Lexer.new("do do do end end end"):tokenize() -- de do do do de da da da
    local result = Parser.new(tokens):parse()

    assert.same({ AST.DoStatement.new({ AST.DoStatement.new({ AST.DoStatement.new({}) }) }) }, result)
  end)
end)
