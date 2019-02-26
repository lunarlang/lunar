local require_dev = require "spec.helpers.require_dev"

describe("LiteralExpression syntax", function()
  require_dev()

  it("should return one NilLiteralExpression node", function()
    local tokens = Lexer.new("nil"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.NilLiteralExpression.new(), result)
  end)

  it("should return one BooleanLiteralExpression node given a value of true", function()
    local tokens = Lexer.new("true"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.BooleanLiteralExpression.new(true), result)
  end)

  it("should return one BooleanLiteralExpression node given a value of false", function()
    local tokens = Lexer.new("false"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.BooleanLiteralExpression.new(false), result)
  end)

  it("should return one NumberLiteralExpression node given a value of 100", function()
    local tokens = Lexer.new("100"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.NumberLiteralExpression.new(100), result)
  end)

  it("should return one StringLiteralExpression node given a string value", function()
    local tokens = Lexer.new("'Hello, world!'"):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.StringLiteralExpression.new("'Hello, world!'"), result)
  end)

  it("should return one VariableArgumentExpression node", function()
    local tokens = Lexer.new("..."):tokenize()
    local result = Parser.new(tokens):expression()

    assert.same(AST.VariableArgumentExpression.new(), result)
  end)

  it("should return one FunctionExpression node whose parameters has two ParameterDeclaration nodes and a BreakStatement block", function()
    local tokens = Lexer.new("function(hello, ...) break end"):tokenize()
    local result = Parser.new(tokens):expression()

    local expected_params = { AST.ParameterDeclaration.new(AST.Identifier.new("hello")), AST.ParameterDeclaration.new(AST.Identifier.new("...")) }
    local expected_block = { AST.BreakStatement.new() }

    assert.same(AST.FunctionExpression.new(expected_params, expected_block), result)
  end)

  it("should return one TableLiteralExpression node with three FieldDeclaration nodes", function()
    local tokens = Lexer.new("{ ['hello'] = true, world = false; nil; }"):tokenize()
    local result = Parser.new(tokens):expression()

    local expected_fields = {
      AST.FieldDeclaration.new(AST.StringLiteralExpression.new("'hello'"), AST.BooleanLiteralExpression.new(true)),
      AST.FieldDeclaration.new(AST.Identifier.new("world"), AST.BooleanLiteralExpression.new(false)),
      AST.FieldDeclaration.new(nil, AST.NilLiteralExpression.new()),
    }

    assert.same(AST.TableLiteralExpression.new(expected_fields), result)
  end)

  it("should return one LambdaExpression node with two arguments and does not implicitly return", function()
    local tokens = Lexer.new("|a, b| do return a + b end"):tokenize()
    local result = Parser.new(tokens):expression()

    local expected_params = {
      AST.ParameterDeclaration.new(AST.Identifier.new("a")),
      AST.ParameterDeclaration.new(AST.Identifier.new("b"))
    }

    local expected_block = {
      AST.ReturnStatement.new({
        AST.BinaryOpExpression.new(
          AST.Identifier.new("a"),
          AST.BinaryOpKind.addition_op,
          AST.Identifier.new("b")
        )
      })
    }

    assert.same(AST.LambdaExpression.new(expected_params, expected_block, false), result)
  end)

  it("should return one LambdaExpression node without any arguments and does not implicitly return", function()
    local tokens = Lexer.new("do return 1 end"):tokenize()
    local result = Parser.new(tokens):expression()

    local expected_block = {
      AST.ReturnStatement.new({ AST.NumberLiteralExpression.new(1) })
    }

    assert.same(AST.LambdaExpression.new({}, expected_block, false), result)
  end)

  it("should return one LambdaExpression node with two arguments and does implicitly return", function()
    local tokens = Lexer.new("|a, b| a + b"):tokenize()
    local result = Parser.new(tokens):expression()

    local expected_params = {
      AST.ParameterDeclaration.new(AST.Identifier.new("a")),
      AST.ParameterDeclaration.new(AST.Identifier.new("b"))
    }

    local expected_expr = AST.BinaryOpExpression.new(
      AST.Identifier.new("a"),
      AST.BinaryOpKind.addition_op,
      AST.Identifier.new("b")
    )

    assert.same(AST.LambdaExpression.new(expected_params, expected_expr, true), result)
  end)
end)
