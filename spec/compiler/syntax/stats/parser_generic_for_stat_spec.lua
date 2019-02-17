local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"
local TokenInfo = require "lunar.compiler.lexical.token_info"
local TokenType = require "lunar.compiler.lexical.token_type"

describe("GenericForStatement syntax", function()
  it("should return one GenericForStatement node with one identifier and one expression", function()
    local tokens = Lexer.new("for i in pairs() do end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_identifiers = { TokenInfo.new(TokenType.identifier, "i", 5) }
    local expected_exprlist = {
      AST.FunctionCallExpression.new(AST.MemberExpression.new(TokenInfo.new(TokenType.identifier, "pairs", 10)), {})
    }

    assert.same({
      AST.GenericForStatement.new(expected_identifiers, expected_exprlist, {})
    }, result)
  end)

  it("should return one GenericForStatement node with two identifiers and one expressions", function()
    local tokens = Lexer.new("for i, v in pairs() do end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_identifiers = {
      TokenInfo.new(TokenType.identifier, "i", 5),
      TokenInfo.new(TokenType.identifier, "v", 8)
    }
    local expected_exprlist = {
      AST.FunctionCallExpression.new(AST.MemberExpression.new(TokenInfo.new(TokenType.identifier, "pairs", 13)), {})
    }

    assert.same({
      AST.GenericForStatement.new(expected_identifiers, expected_exprlist, {})
    }, result)
  end)

  it("should return one GenericForStatement node with two identifiers and two expressions", function()
    local tokens = Lexer.new("for i, v in next, t do end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_identifiers = {
      TokenInfo.new(TokenType.identifier, "i", 5),
      TokenInfo.new(TokenType.identifier, "v", 8)
    }
    local expected_exprlist = {
      AST.MemberExpression.new(TokenInfo.new(TokenType.identifier, "next", 13)),
      AST.MemberExpression.new(TokenInfo.new(TokenType.identifier, "t", 19))
    }

    assert.same({
      AST.GenericForStatement.new(expected_identifiers, expected_exprlist, {})
    }, result)
  end)
end)
