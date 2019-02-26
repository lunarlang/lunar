local require_dev = require "spec.helpers.require_dev"

describe("FunctionStatement syntax", function()
  require_dev()

  it("should return one FunctionStatement node with a MemberExpression named test and two ParameterDeclaration", function()
    local tokens = Lexer.new("function test(a, b) end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_name = AST.MemberExpression.new("test")
    local expected_params = {
      AST.ParameterDeclaration.new("a"),
      AST.ParameterDeclaration.new("b")
    }

    assert.same({
      AST.FunctionStatement.new(expected_name, expected_params, {}, nil)
    }, result)
  end)

  it("should return one FunctionStatement node with a MemberExpression of a.b:c", function()
    local tokens = Lexer.new("function a.b:c() end"):tokenize()
    local result = Parser.new(tokens):parse()

    local root_member_expr = AST.MemberExpression.new("a")
    local middle_member_expr = AST.MemberExpression.new(root_member_expr, "b")
    local top_member_expr = AST.MemberExpression.new(middle_member_expr, "c", true)

    assert.same({
      AST.FunctionStatement.new(top_member_expr, {}, {}, nil)
    }, result)
  end)

  it("should return a FunctionStatement node whose definition was local", function()
    local tokens = Lexer.new("local function test() end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.FunctionStatement.new("test", {}, {}, nil, true)
    }, result)
  end)

  it("should attach return type annotation", function()
    local tokens = Lexer.new("local function test(): string end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.FunctionStatement.new("test", {}, {}, "string", true)
    }, result)
  end)
end)
