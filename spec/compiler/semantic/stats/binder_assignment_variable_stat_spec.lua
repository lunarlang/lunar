local require_dev = require "spec.helpers.require_dev"

describe("AssignmentStatement syntax", function()
  require_dev()

  it("should bind an global identifier as a declaration", function()
    local tokens = Lexer.new("hello = 1"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(AST.Chunk.new(result)):bind()

    local assignment = result[1]
    local identifier = assignment.variables[1]

    assert.truthy(identifier.symbol)
    assert.equal(assignment, identifier.symbol.declaration)
  end)

  it("should bind a local identifier as a declaration", function()
    local tokens = Lexer.new("local hello"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(AST.Chunk.new(result)):bind()

    local variable_statement = result[1]
    local identifier = variable_statement.identlist[1]

    assert.truthy(identifier.symbol)
    assert.equal(variable_statement, identifier.symbol.declaration)
  end)

  it("should bind a two variable statements of the same name with separate symbols and declarations", function()
    local tokens = Lexer.new("local hello; local hello"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(AST.Chunk.new(result)):bind()

    local variable_statement_1 = result[1]
    local identifier_1 = variable_statement_1.identlist[1]
    local variable_statement_2 = result[2]
    local identifier_2 = variable_statement_2.identlist[1]
    
    assert.is_not.equal(identifier_1.symbol, identifier_2.symbol)
    assert.is_not.equal(identifier_1.symbol.declaration, identifier_2.symbol.declaration)

    assert.truthy(identifier_1.symbol)
    assert.equal(variable_statement_1, identifier_1.symbol.declaration)

    assert.truthy(identifier_2.symbol)
    assert.equal(variable_statement_2, identifier_2.symbol.declaration)
  end)

  it("should bind initial global assignments as declarations, and any preceding with the same symbol", function()
    local tokens = Lexer.new("hello = 1; hello = 2"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(AST.Chunk.new(result)):bind()

    local assignment_1 = result[1]
    local identifier_1 = assignment_1.variables[1]
    local assignment_2 = result[2]
    local identifier_2 = assignment_2.variables[1]
    
    assert.truthy(identifier_1.symbol)
    assert.equal(assignment_1, identifier_1.symbol.declaration)
    assert.equal(identifier_1.symbol, identifier_2.symbol)
  end)

  it("should allow re-declaration of globals in a new scope", function()
    local tokens = Lexer.new("hello = 1; local hello = 2"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(AST.Chunk.new(result)):bind()

    local assignment_1 = result[1]
    local identifier_1 = assignment_1.variables[1]
    local variable_statement_2 = result[2]
    local identifier_2 = variable_statement_2.identlist[1]
    
    assert.truthy(identifier_1.symbol)
    assert.truthy(identifier_2.symbol)
    assert.is_not.equal(identifier_1.symbol, identifier_2.symbol)
    assert.equal(assignment_1, identifier_1.symbol.declaration)
    assert.equal(variable_statement_2, identifier_2.symbol.declaration)
  end)
end)
