local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("FunctionStatement syntax", function()
  it("should return one FunctionStatement node with a MemberExpression named test and two ParameterDeclaration", function()
    local tokens = Lexer.new("function test(a, b) end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_name = AST.MemberExpression.new(TokenInfo.new(TokenType.identifier, "test", 10))
    local expected_params = {
      AST.ParameterDeclaration.new('a'),
      AST.ParameterDeclaration.new('b')
    }

    assert.same({
      AST.FunctionStatement.new(expected_name, expected_params, {})
    }, result)
  end)

  it("should return one FunctionStatement node with a MemberExpression of a.b:c", function()
    local tokens = Lexer.new("function a.b:c() end"):tokenize()
    local result = Parser.new(tokens):parse()

    local root_member_expr = AST.MemberExpression.new(TokenInfo.new(TokenType.identifier, "a", 10))
    local middle_member_expr = AST.MemberExpression.new(root_member_expr, TokenInfo.new(TokenType.identifier, "b", 12))
    local top_member_expr = AST.MemberExpression.new(middle_member_expr, TokenInfo.new(TokenType.identifier, "c", 14), true)

    assert.same({
      AST.FunctionStatement.new(top_member_expr, {}, {})
    }, result)
  end)

  it("should return a FunctionStatement node whose definition was local", function()
    local tokens = Lexer.new("local function test() end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.FunctionStatement.new("test", {}, {}, true)
    }, result)
  end)
end)
