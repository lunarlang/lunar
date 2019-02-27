local require_dev = require "spec.helpers.require_dev"

describe("Bindings on regular local and global variable declarations", function()
  require_dev()

  it("should bind a global identifier as assigned with no declaration", function()
    local tokens = Lexer.new("hello = 1"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local assignment = result[1]
    local identifier = assignment.variables[1]

    assert.truthy(identifier.symbol)
    assert.truthy(identifier.symbol.is_assigned)
    assert.falsy(identifier.symbol.declaration)
  end)

  it("should bind a local identifier as a declaration and as not assigned", function()
    local tokens = Lexer.new("local hello"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local variable_statement = result[1]
    local identifier = variable_statement.identlist[1]

    assert.truthy(identifier.symbol)
    assert.falsy(identifier.symbol.is_assigned)
    assert.equal(variable_statement, identifier.symbol.declaration)
  end)

  it("should bind a local identifier as a declaration and as assigned", function()
    local tokens = Lexer.new("local hello = 1"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local variable_statement = result[1]
    local identifier = variable_statement.identlist[1]

    assert.truthy(identifier.symbol)
    assert.truthy(identifier.symbol.is_assigned)
    assert.equal(variable_statement, identifier.symbol.declaration)
  end)

  it("should bind a two local identifiers with separate symbols and declarations; both should not be assigned", function()
    local tokens = Lexer.new("local hello; local hello"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local variable_statement_1 = result[1]
    local identifier_1 = variable_statement_1.identlist[1]
    local variable_statement_2 = result[2]
    local identifier_2 = variable_statement_2.identlist[1]
    
    assert.is_not.equal(identifier_1.symbol, identifier_2.symbol)
    assert.is_not.equal(identifier_1.symbol.declaration, identifier_2.symbol.declaration)

    assert.truthy(identifier_1.symbol)
    assert.falsy(identifier_1.symbol.is_assigned)
    assert.equal(variable_statement_1, identifier_1.symbol.declaration)

    assert.truthy(identifier_2.symbol)
    assert.falsy(identifier_1.symbol.is_assigned)
    assert.equal(variable_statement_2, identifier_2.symbol.declaration)
  end)

  it("should bind global assignments with the same symbol and no declaration", function()
    local tokens = Lexer.new("hello = 1; hello = 2"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local assignment_1 = result[1]
    local identifier_1 = assignment_1.variables[1]
    local assignment_2 = result[2]
    local identifier_2 = assignment_2.variables[1]
    
    assert.truthy(identifier_1.symbol)
    assert.truthy(identifier_1.symbol.is_assigned)
    assert.truthy(identifier_2.symbol)
    assert.truthy(identifier_2.symbol.is_assigned)
    assert.equal(identifier_1.symbol, identifier_2.symbol)
    assert.falsy(identifier_1.symbol.declaration)
  end)

  it("should allow re-declaration of globals in a new scope; local symbol should be a declaration", function()
    local tokens = Lexer.new("hello = 1; local hello = 2"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local assignment_1 = result[1]
    local identifier_1 = assignment_1.variables[1]
    local variable_statement_2 = result[2]
    local identifier_2 = variable_statement_2.identlist[1]
    
    assert.truthy(identifier_1.symbol)
    assert.truthy(identifier_1.symbol.is_assigned)
    assert.truthy(identifier_2.symbol)
    assert.truthy(identifier_2.symbol.is_assigned)
    assert.is_not.equal(identifier_1.symbol, identifier_2.symbol)
    assert.falsy(identifier_1.symbol.declaration)
    assert.equal(variable_statement_2, identifier_2.symbol.declaration)
  end)
end)
