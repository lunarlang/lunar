local require_dev = require "spec.helpers.require_dev"

describe("Bindings of class statements", function()
  require_dev()

  it("should bind the class value as a local value symbol with no global bindings", function()
    local tokens = Lexer.new("class MyClass end"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    local class_stat = result[1]
    local identifier = class_stat.identifier

    assert.truthy(identifier.symbol)
    assert.True(identifier.symbol.is_assigned)
    assert.False(identifier.symbol.is_referenced)
    assert.truthy(identifier.symbol.declaration)
    assert.False(env.globals:has_value("MyClass"))
    assert.False(env.globals:has_type("MyClass"))
  end)

  it("should bind the class local value and type symbols", function()
    local tokens = Lexer.new("class MyClass end; local x: MyClass"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local class_stat = result[1]
    local var_stat = result[2]
    local var_ident = var_stat.identlist[1]

    assert.truthy(var_ident.type_annotation)
    assert.truthy(var_ident.type_annotation.symbol)
    assert.truthy(var_ident.type_annotation.symbol.declaration)
    assert.True(var_ident.type_annotation.symbol.is_assigned)
    assert.True(var_ident.type_annotation.symbol.is_referenced)
    assert.equal(class_stat, var_ident.type_annotation.symbol.declaration)
  end)

  it("should bind a variable reference to superclasses, but no type reference", function()
    local tokens = Lexer.new("class S end; class C << S end"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    local super_class_stat = result[1]
    local super_class_ident = super_class_stat.identifier
    local sub_class_stat = result[2]
    local sub_class_super_ident = sub_class_stat.super_identifier

    assert.truthy(super_class_ident.symbol)
    assert.True(super_class_ident.symbol.is_assigned)
    assert.True(super_class_ident.symbol.is_referenced)
    assert.truthy(super_class_ident.symbol.declaration)
    assert.equal(super_class_stat, super_class_ident.symbol.declaration)
    assert.equal(super_class_ident.symbol, sub_class_super_ident.symbol)
    assert.False(env.globals:has_value("C"))
    assert.False(env.globals:has_type("C"))
    assert.False(env.globals:has_value("S"))
    assert.False(env.globals:has_type("S"))
  end)

  it("should bind member function symbols inside of the class symbol members table", function()
    local tokens = Lexer.new("class X function Y() end end"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    local class_stat = result[1]
    
    local class_ident = class_stat.identifier
    assert.truthy(class_ident.symbol)

    local members = class_ident.symbol.members
    assert.truthy(members)

    assert.True(members:has_value("Y"))
    assert.False(class_ident.symbol.exports:has_value("Y"))
    assert.False(env.globals:has_value("X"))
    assert.False(env.globals:has_type("X"))
    assert.False(env.globals:has_value("Y"))
  end)

  it("should bind static function symbols inside of the class symbol statics table", function()
    local tokens = Lexer.new("class X static function Y() end end"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    local class_stat = result[1]
    
    local class_ident = class_stat.identifier
    assert.truthy(class_ident.symbol)

    local statics = class_ident.symbol.exports
    assert.truthy(statics)

    assert.True(statics:has_value("Y"))
    assert.False(class_ident.symbol.members:has_value("Y"))
    assert.False(env.globals:has_value("X"))
    assert.False(env.globals:has_type("X"))
    assert.False(env.globals:has_value("Y"))
  end)

  it("should bind instance fields to class symbol members table", function()
    local tokens = Lexer.new("class X static Y end"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    local class_stat = result[1]
    
    local class_ident = class_stat.identifier
    assert.truthy(class_ident.symbol)

    local statics = class_ident.symbol.exports
    assert.truthy(statics)

    assert.True(statics:has_value("Y"))
    assert.False(class_ident.symbol.members:has_value("Y"))
    assert.False(env.globals:has_value("X"))
    assert.False(env.globals:has_type("X"))
    assert.False(env.globals:has_value("Y"))
  end)

  it("should error upon redeclaration of of the same field", function()
    local tokens = Lexer.new("class X Y Y end"):tokenize()
    local result = Parser.new(tokens):parse()
    local bind_step = function()
      Binder.new(result):bind()
    end
    assert.has_errors(bind_step)
  end)

  it("should allow declaration of static and instance fields of the same name", function()
    local tokens = Lexer.new("class X Y static Y end"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local class_stat = result[1]
    
    local class_ident = class_stat.identifier
    assert.truthy(class_ident.symbol)

    local members = class_ident.symbol.members
    local statics = class_ident.symbol.exports
    assert.truthy(members)
    assert.truthy(statics)

    assert.True(members:has_value("Y"))
    assert.True(statics:has_value("Y"))
  end)

  it("should bind constructor declaration to class statics", function()
    local tokens = Lexer.new("class X constructor() end end"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local class_stat = result[1]
    
    local class_ident = class_stat.identifier
    assert.truthy(class_ident.symbol)

    local members = class_ident.symbol.members
    local statics = class_ident.symbol.exports
    assert.truthy(members)
    assert.truthy(statics)

    assert.False(members:has_value("constructor"))
    assert.True(statics:has_value("constructor"))
  end)

  it("should guard against constructor re-declaration", function()
    local tokens = Lexer.new("class X constructor() end constructor() end end"):tokenize()
    local result = Parser.new(tokens):parse()
    local bind_step = function()
      Binder.new(result):bind()
    end
    assert.has_errors(bind_step)
  end)

  it("should localize class value symbols but spread class type symbols within the source's scope", function()
    local tokens = Lexer.new("local obj: X = X.new() class X end"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    local ident = result[1].identlist[1]
    local ident_expr_global = result[1].exprlist[1].base.base
    local class_stat = result[2]
    
    local class_ident = class_stat.identifier
    assert.truthy(class_ident.symbol)

    -- Check value symbol
    assert.truthy(ident_expr_global.symbol)
    assert.falsy(ident_expr_global.symbol.declaration)
    assert.False(ident_expr_global.symbol.is_assigned)
    assert.True(ident_expr_global.symbol.is_referenced)

    -- Check type symbol
    assert.truthy(ident.type_annotation)
    assert.truthy(ident.type_annotation.symbol)
    assert.True(ident.type_annotation.symbol.is_assigned)
    assert.True(ident.type_annotation.symbol.is_referenced)
    assert.equal(class_stat, ident.type_annotation.symbol.declaration)

    assert.True(env.globals:has_value("X"))
    assert.False(env.globals:has_type("X"))
  end)
  
end)