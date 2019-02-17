local AST = require "lunar.ast"
local Lexer = require "lunar.compiler.lexical.lexer"
local Parser = require "lunar.compiler.syntax.parser"

describe("IfStatement syntax", function()
  it("should return one IfStatement node", function()
    local tokens = Lexer.new("if true then end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_expr = AST.BooleanLiteralExpression.new(true)

    assert.same({ AST.IfStatement.new(expected_expr, {}) }, result)
  end)

  it("should return one IfStatement node with one elseif branch", function()
    local tokens = Lexer.new("if false then elseif false then end"):tokenize()
    local result = Parser.new(tokens):parse()

    -- since all branches here has the same
    local expected_expr = AST.BooleanLiteralExpression.new(false)

    assert.same({
      AST.IfStatement.new(expected_expr, {})
        :push_elseif(AST.IfStatement.new(expected_expr, {}))
    }, result)
  end)

  it("should return one IfStatement node with one elseif branch and an else branch #prob", function()
    local tokens = Lexer.new("if false then elseif false then else end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_expr = AST.BooleanLiteralExpression.new(false)

    assert.same({
      AST.IfStatement.new(expected_expr, {})
        :push_elseif(AST.IfStatement.new(expected_expr, {}, {}))
        :set_else(AST.IfStatement.new(nil, {}))
    }, result)
  end)

  it("should return nested IfStatement nodes", function()
    local tokens = Lexer.new("if false then if false then end end"):tokenize()
    local result = Parser.new(tokens):parse()

    local expected_expr = AST.BooleanLiteralExpression.new(false)

    assert.same({
      AST.IfStatement.new(expected_expr, { AST.IfStatement.new(expected_expr, {}) })
    }, result)
  end)
end)
