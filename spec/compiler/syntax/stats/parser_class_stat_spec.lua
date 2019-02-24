local require_dev = require "spec.helpers.require_dev"

describe("ClassStatement syntax", function()
  require_dev()

  it("should return one ClassStatement node whose name is 'C'", function()
    local tokens = Lexer.new("class C end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({ AST.ClassStatement.new("C", nil, {}) }, result)
  end)

  it("should return one ClassStatement node whose name is 'C' and inherits from 'BaseC'", function()
    local tokens = Lexer.new("class C << BaseC end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({ AST.ClassStatement.new("C", "BaseC", {}) }, result)
  end)

  it("should return one ClassStatement node with one instance function", function()
    local tokens = Lexer.new("class C function m() end end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.ClassStatement.new("C", nil, {
        AST.ClassFunctionDeclaration.new(false, "m", {}, {})
      })
    }, result)
  end)

  it("should return one ClassStatement node with one static function", function()
    local tokens = Lexer.new("class C static function m() end end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.ClassStatement.new("C", nil, {
        AST.ClassFunctionDeclaration.new(true, "m", {}, {})
      })
    }, result)
  end)

  it("should return one ClassStatement node with one constructor", function()
    local tokens = Lexer.new("class C constructor() end end"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.ClassStatement.new("C", nil, {
        AST.ConstructorDeclaration.new({}, {})
      })
    }, result)
  end)

  it("should not return one ClassStatement node but instead return an ExpressionStatement calling 'class'", function()
    local tokens = Lexer.new("class()"):tokenize()
    local result = Parser.new(tokens):parse()

    assert.same({
      AST.ExpressionStatement.new(AST.FunctionCallExpression.new(AST.MemberExpression.new("class"), {}))
    }, result)
  end)
end)
