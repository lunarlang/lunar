local require_dev = require "spec.helpers.require_dev"

describe("Bindings of type expressions", function()
  require_dev()

  it("should bind type identifiers as global references in type annotation", function()
    local tokens = Lexer.new("local x: undeclared_type"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    env:link_external_references()

    local var_stat = result[1]
    local x_ident = var_stat.identlist[1]
    local type_annotation = x_ident.type_annotation

    assert.truthy(type_annotation.symbol)
    assert.True(type_annotation.symbol:is_referenced())
    assert.False(type_annotation.symbol:is_assigned())
    assert.False(type_annotation.symbol:is_builtin())
    assert.False(type_annotation.symbol:is_declared())

    assert.equal(env:get_global_type('src', 'undeclared_type'), type_annotation.symbol)
  end)

  it("should bind type identifiers to core types", function()
    local tokens = Lexer.new("local x: string"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    env:link_external_references()

    local var_stat = result[1]
    local x_ident = var_stat.identlist[1]
    local type_annotation = x_ident.type_annotation

    assert.truthy(type_annotation.symbol)
    assert.True(type_annotation.symbol:is_referenced())
    assert.False(type_annotation.symbol:is_assigned())
    assert.True(type_annotation.symbol:is_builtin())
    assert.False(type_annotation.symbol:is_declared())

    assert.equal(CoreGlobals:get_type('string'), type_annotation.symbol)
  end)

  it("should bind type identifiers as global references in type assertion", function()
    local tokens = Lexer.new("local x = '3' as undeclared_type"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    env:link_external_references()

    local var_stat = result[1]
    local type_assertion = var_stat.exprlist[1]
    local type_ident = type_assertion.type

    assert.truthy(type_ident.symbol)
    assert.True(type_ident.symbol:is_referenced())
    assert.False(type_ident.symbol:is_assigned())
    assert.False(type_ident.symbol:is_builtin())
    assert.False(type_ident.symbol:is_declared())

    assert.equal(env:get_global_type('src', 'undeclared_type'), type_ident.symbol)
  end)
  
end)