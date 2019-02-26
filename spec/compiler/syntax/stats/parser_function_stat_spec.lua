local require_dev = require "spec.helpers.require_dev"

describe("FunctionStatement syntax", function()
  require_dev()

  it("should return one FunctionStatement node with an Identifier named test and two ParameterDeclaration", function()
    local tokens = Lexer.new("function test(a, b) end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_name = AST.Identifier.new("test")
    local expected_params = {
      AST.ParameterDeclaration.new(AST.Identifier.new("a")),
      AST.ParameterDeclaration.new(AST.Identifier.new("b"))
    }

    assert.same({
      AST.FunctionStatement.new(expected_name, expected_params, {}, nil)
    }, result)
  end)

  it("should return one FunctionStatement node with a MemberExpression of a.b:c", function()
    local tokens = Lexer.new("function a.b:c() end"):tokenize()
    local result = Parser.new(tokens):parse()

    local root_ident = AST.Identifier.new("a")
    local middle_member_expr = AST.MemberExpression.new(root_ident, AST.Identifier.new("b"))
    local top_member_expr = AST.MemberExpression.new(middle_member_expr, AST.Identifier.new("c"), true)

    assert.same({
      AST.FunctionStatement.new(top_member_expr, {}, {}, nil)
    }, result)
  end)

  it("should return a FunctionStatement node whose definition was local", function()
    local tokens = Lexer.new("local function test() end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.FunctionStatement.new(AST.Identifier.new("test"), {}, {}, nil, true)
    }, result)
  end)

  it("should attach return type annotation", function()
    local tokens = Lexer.new("local function test(): string end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.FunctionStatement.new(AST.Identifier.new("test"), {}, {}, AST.Identifier.new("string"), true)
    }, result)
  end)

  it("should attach type annotation to formal parameters", function()
    local tokens = Lexer.new("function test(a: string, b, c: any) end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_name = AST.MemberExpression.new("test")
    local expected_params = {
      AST.ParameterDeclaration.new("a", "string"),
      AST.ParameterDeclaration.new("b", nil),
      AST.ParameterDeclaration.new("c", "any")
    }

    assert.same({
      AST.FunctionStatement.new(expected_name, expected_params, {}, nil)
    }, result)
  end)
end)
