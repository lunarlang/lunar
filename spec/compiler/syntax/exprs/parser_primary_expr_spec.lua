local require_dev = require "spec.helpers.require_dev"

describe("SecondaryExpression syntax", function()
  require_dev()

  it("should return a FunctionCallExpression with no arguments", function()
    local tokens = Lexer.new("hello()"):tokenize()
    local result = Parser.new(tokens):expression()

    local base = AST.Identifier.new("hello")
    local args = {}

    assert.same(AST.FunctionCallExpression.new(base, args), result)
  end)

  it("should return a FunctionCallExpression with three NumberLiteralExpression arguments", function()
    local tokens = Lexer.new("testing(1, 2, 3)"):tokenize()
    local result = Parser.new(tokens):expression()

    local base = AST.Identifier.new("testing")
    local args = {
      AST.ArgumentExpression.new(AST.NumberLiteralExpression.new(1)),
      AST.ArgumentExpression.new(AST.NumberLiteralExpression.new(2)),
      AST.ArgumentExpression.new(AST.NumberLiteralExpression.new(3))
    }

    assert.same(AST.FunctionCallExpression.new(base, args), result)
  end)

  it("should return a FunctionCallExpression with a MemberExpression using bracket syntax", function()
    local tokens = Lexer.new("thank['you'](kanye)"):tokenize()
    local result = Parser.new(tokens):expression()

    local right_member = AST.StringLiteralExpression.new("'you'")
    local top_member = AST.MemberExpression.new(AST.Identifier.new("thank"), right_member)
    local args = { AST.ArgumentExpression.new(AST.Identifier.new("kanye")) }

    assert.same(AST.FunctionCallExpression.new(top_member, args), result)
  end)

  it("should return a FunctionCallExpression with dot syntax", function()
    local tokens = Lexer.new("very.cool()"):tokenize()
    local result = Parser.new(tokens):expression()

    local top_member = AST.MemberExpression.new(AST.Identifier.new("very"), AST.Identifier.new("cool"))
    local args = {}

    assert.same(AST.FunctionCallExpression.new(top_member, args), result)
  end)

  it("should return a FunctionCallExpression with colon syntax", function()
    local tokens = Lexer.new("very:nice()"):tokenize()
    local result = Parser.new(tokens):expression()

    local top_member = AST.MemberExpression.new(AST.Identifier.new("very"), AST.Identifier.new("nice"), true)
    local args = {}

    assert.same(AST.FunctionCallExpression.new(top_member, args), result)
  end)

  it("should return a FunctionCallExpression with a string argument", function()
    local tokens = Lexer.new("cool'stuff'"):tokenize()
    local result = Parser.new(tokens):expression()

    local base = AST.Identifier.new("cool")
    local args = { AST.ArgumentExpression.new(AST.StringLiteralExpression.new("'stuff'")) }

    assert.same(AST.FunctionCallExpression.new(base, args), result)
  end)

  it("should return a FunctionCallExpression with a table argument", function()
    local tokens = Lexer.new("help{}"):tokenize()
    local result = Parser.new(tokens):expression()

    local base = AST.Identifier.new("help")
    local args = { AST.ArgumentExpression.new(AST.TableLiteralExpression.new({})) }

    assert.same(AST.FunctionCallExpression.new(base, args), result)
  end)
end)
