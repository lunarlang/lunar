local require_dev = require "spec.helpers.require_dev"

describe("Bindings of declared identifiers", function()
  require_dev()

  it("should declare global symbols with a separate assignment", function()
    local tokens = Lexer.new("declare global x; x = 2"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    env:link_external_references()

    local dec_ident = result[1].identifier
    local assign_ident = result[2].variables[1]

    assert.truthy(dec_ident.symbol)
    assert.truthy(assign_ident.symbol)
    assert.equal(dec_ident.symbol, assign_ident.symbol)

    assert.equal(result[1], dec_ident.symbol:get_canonical_declaration())
    assert.True(dec_ident.symbol:is_assigned())
    assert.False(dec_ident.symbol:is_referenced())

    assert.equal(dec_ident.symbol, env:get_global_value('src', 'x'))
  end)

  it("should allow declaration of return type symbols for external packages", function()
    local tokens = Lexer.new("declare package 'x' string"):tokenize()
    local result = Parser.new(tokens):parse()

    local env = ProjectEnvironment.new()
    Binder.new(result, env):bind()

    local dec_stat = result[1]

    local package_env_symbol = env:get_returns_symbol('x')

    assert.truthy(package_env_symbol)
    assert.equal(dec_stat, package_env_symbol:get_canonical_declaration())
    assert.False(package_env_symbol:is_assigned())
    assert.False(package_env_symbol:is_referenced())
  end)
  

  it("should bind import aliases to declared external packages", function()
    local tokens = Lexer.new("declare package 'x' string; from 'x' import * as x; print(x)"):tokenize()
    local result = Parser.new(tokens):parse()

    local env = ProjectEnvironment.new()
    Binder.new(result, env):bind()

    -- link
    env:link_external_references()

    local dec_stat = result[1]
    local import_stat = result[2]
    local expr_stat = result[3]

    local package_alias_ident = expr_stat.expr.arguments[1].value
    local package_env_symbol = env:get_returns_symbol('x')

    assert.truthy(package_alias_ident.symbol)
    assert.truthy(package_env_symbol)
    assert.is_not.equal(package_env_symbol, package_alias_ident.symbol)

    assert.equal(import_stat, package_alias_ident.symbol:get_canonical_declaration())
    assert.True(package_alias_ident.symbol:is_assigned())
    assert.True(package_alias_ident.symbol:is_referenced())

    assert.equal(dec_stat, package_env_symbol:get_canonical_declaration())
    assert.False(package_env_symbol:is_assigned())
    assert.True(package_env_symbol:is_referenced())
  end)

  it("should allow declaration of return type symbols within a local source file", function()
    local env = ProjectEnvironment.new()

    -- file 'x'
    local tokens_x = Lexer.new("declare returns string"):tokenize()
    local result_x = Parser.new(tokens_x):parse()
    Binder.new(result_x, env, 'x'):bind()

    local dec_stat = result_x[1]

    -- file 'y'
    local tokens_y = Lexer.new("from 'x' import * as x; print(x)"):tokenize()
    local result_y = Parser.new(tokens_y):parse()
    Binder.new(result_y, env, 'y'):bind()
    local import_stat = result_y[1]
    local expr_stat = result_y[2]

    -- link
    env:link_external_references()

    local package_alias_ident = expr_stat.expr.arguments[1].value
    local package_env_symbol = env:get_returns_symbol('x')

    assert.truthy(package_alias_ident.symbol)
    assert.truthy(package_env_symbol)
    assert.is_not.equal(package_env_symbol, package_alias_ident.symbol)

    assert.equal(import_stat, package_alias_ident.symbol:get_canonical_declaration())
    assert.True(package_alias_ident.symbol:is_assigned())
    assert.True(package_alias_ident.symbol:is_referenced())

    assert.equal(dec_stat, package_env_symbol:get_canonical_declaration())
    assert.False(package_env_symbol:is_assigned())
    assert.True(package_env_symbol:is_referenced())
  end)

  it("should allow implicit declaration of return type symbols within a local source file", function()
    local env = ProjectEnvironment.new()

    -- file 'x'
    local tokens_x = Lexer.new("return 'Hello, world!'"):tokenize()
    local result_x = Parser.new(tokens_x):parse()
    Binder.new(result_x, env, 'x'):bind()

    local return_stat = result_x[1]

    -- file 'y'
    local tokens_y = Lexer.new("from 'x' import * as x; print(x)"):tokenize()
    local result_y = Parser.new(tokens_y):parse()
    Binder.new(result_y, env, 'y'):bind()
    local import_stat = result_y[1]
    local expr_stat = result_y[2]

    -- link
    env:link_external_references()

    local package_alias_ident = expr_stat.expr.arguments[1].value
    local package_env_symbol = env:get_returns_symbol('x')

    assert.truthy(package_alias_ident.symbol)
    assert.truthy(package_env_symbol)
    assert.is_not.equal(package_env_symbol, package_alias_ident.symbol)

    assert.equal(import_stat, package_alias_ident.symbol:get_canonical_declaration())
    assert.True(package_alias_ident.symbol:is_assigned())
    assert.True(package_alias_ident.symbol:is_referenced())

    assert.equal(return_stat, package_env_symbol:get_canonical_declaration())
    assert.False(package_env_symbol:is_assigned())
    assert.True(package_env_symbol:is_referenced())
  end)

  it("should allow implicit declaration of export symbols within a local source file", function()
    local env = ProjectEnvironment.new()

    -- file 'x'
    local tokens_x = Lexer.new("export x = 'Hello, world!'"):tokenize()
    local result_x = Parser.new(tokens_x):parse()
    Binder.new(result_x, env, 'x'):bind()

    local export_stat = result_x[1]
    local export_inner_stat = export_stat.body

    -- file 'y'
    local tokens_y = Lexer.new("from 'x' import x; print(x)"):tokenize()
    local result_y = Parser.new(tokens_y):parse()
    Binder.new(result_y, env, 'y'):bind()
    local import_stat = result_y[1]
    local expr_stat = result_y[2]

    -- link
    env:link_external_references()

    local package_alias_ident = expr_stat.expr.arguments[1].value
    local package_env_symbol = env:get_returns_symbol('x')

    assert.truthy(package_alias_ident.symbol)
    assert.truthy(package_env_symbol)
    assert.is_not.equal(package_env_symbol, package_alias_ident.symbol)

    local export_symbol = package_env_symbol.exports:get_value('x')

    assert.truthy(export_symbol)
    assert.is_not.equal(export_symbol, package_alias_ident.symbol)
    assert.equal(export_inner_stat, export_symbol:get_canonical_declaration())
    assert.True(export_symbol:is_assigned())
    assert.True(export_symbol:is_referenced())

    assert.equal(import_stat, package_alias_ident.symbol:get_canonical_declaration())
    assert.True(package_alias_ident.symbol:is_assigned())
    assert.True(package_alias_ident.symbol:is_referenced())

    assert.False(package_env_symbol:is_declared())
    assert.False(package_env_symbol:is_assigned())
    assert.False(package_env_symbol:is_referenced())
  end)

  it("should allow imports of standalone class type symbols", function()
    local env = ProjectEnvironment.new()

    -- file 'x'
    local tokens_x = Lexer.new("export class MyClass end"):tokenize()
    local result_x = Parser.new(tokens_x):parse()
    Binder.new(result_x, env, 'x'):bind()

    local export_stat = result_x[1]
    local export_inner_stat = export_stat.body

    -- file 'y'
    local tokens_y = Lexer.new("from 'x' import type MyClass; print(MyClass); local y: MyClass"):tokenize()
    local result_y = Parser.new(tokens_y):parse()
    Binder.new(result_y, env, 'y'):bind()
    local import_stat = result_y[1]
    local expr_stat = result_y[2]
    local var_stat = result_y[3]

    -- link
    env:link_external_references()

    local package_alias_value_ident = expr_stat.expr.arguments[1].value
    local package_alias_type_ident = var_stat.identlist[1].type_annotation
    local package_env_symbol = env:get_returns_symbol('x')
    local global_env_symbol = env:get_global_value('y', 'MyClass')

    assert.truthy(package_env_symbol)

    -- Value symbol for 'MyClass' should bind as global, since it is not imported
    assert.truthy(package_alias_value_ident.symbol)
    assert.is_not.equal(package_env_symbol, package_alias_value_ident.symbol)
    assert.truthy(global_env_symbol)
    assert.False(global_env_symbol:is_declared())
    assert.False(global_env_symbol:is_assigned())
    assert.True(global_env_symbol:is_referenced())
    assert.equal(global_env_symbol, package_alias_value_ident.symbol)

    local export_type_symbol = package_env_symbol.exports:get_type('MyClass')
    local export_value_symbol = package_env_symbol.exports:get_value('MyClass')
    assert.is_not_equal(export_type_symbol, export_value_symbol)

    -- Type symbol for 'MyClass' should bind as an alias to the package export type
    assert.truthy(package_alias_type_ident.symbol)
    assert.equal(import_stat, package_alias_type_ident.symbol:get_canonical_declaration())
    assert.True(package_alias_type_ident.symbol:is_assigned())
    assert.True(package_alias_type_ident.symbol:is_referenced())

    assert.truthy(export_type_symbol)
    assert.truthy(export_value_symbol)
    assert.is_not.equal(export_type_symbol, package_alias_value_ident.symbol)
    assert.is_not.equal(export_value_symbol, package_alias_value_ident.symbol)

    assert.False(package_alias_value_ident.symbol:is_declared())
    assert.False(package_alias_value_ident.symbol:is_assigned())
    assert.True(package_alias_value_ident.symbol:is_referenced())

    assert.False(package_env_symbol:is_declared())
    assert.False(package_env_symbol:is_assigned())
    assert.False(package_env_symbol:is_referenced())

    assert.equal(export_inner_stat, export_type_symbol:get_canonical_declaration())
    assert.True(export_type_symbol:is_assigned())
    assert.True(export_type_symbol:is_referenced())

    assert.equal(export_inner_stat, export_value_symbol:get_canonical_declaration())
    assert.True(export_value_symbol:is_assigned())
    assert.False(export_value_symbol:is_referenced())
  end)

  it("should allow import class type symbols with class value symbols", function()
    local env = ProjectEnvironment.new()

    -- file 'x'
    local tokens_x = Lexer.new("export class MyClass end"):tokenize()
    local result_x = Parser.new(tokens_x):parse()
    Binder.new(result_x, env, 'x'):bind()

    local export_stat = result_x[1]
    local export_inner_stat = export_stat.body

    -- file 'y'
    local tokens_y = Lexer.new("from 'x' import MyClass; print(MyClass); local y: MyClass"):tokenize()
    local result_y = Parser.new(tokens_y):parse()
    Binder.new(result_y, env, 'y'):bind()
    local import_stat = result_y[1]
    local expr_stat = result_y[2]
    local var_stat = result_y[3]

    -- link
    env:link_external_references()

    local package_alias_value_ident = expr_stat.expr.arguments[1].value
    local package_alias_type_ident = var_stat.identlist[1].type_annotation
    local package_env_symbol = env:get_returns_symbol('x')

    assert.truthy(package_env_symbol)

    local export_type_symbol = package_env_symbol.exports:get_type('MyClass')
    local export_value_symbol = package_env_symbol.exports:get_value('MyClass')
    assert.truthy(export_type_symbol)
    assert.truthy(export_value_symbol)
    assert.is_not.equal(export_type_symbol, export_value_symbol)
    assert.is_not.equal(export_type_symbol, package_alias_type_ident.symbol)
    assert.is_not.equal(export_value_symbol, package_alias_value_ident.symbol)

    -- Type symbol for 'MyClass' should bind as an alias to the package export type
    assert.truthy(package_alias_type_ident.symbol)
    assert.equal(import_stat, package_alias_type_ident.symbol:get_canonical_declaration())
    assert.True(package_alias_type_ident.symbol:is_assigned())
    assert.True(package_alias_type_ident.symbol:is_referenced())

    -- Value symbol for 'MyClass' should bind as an alias to the package export type
    assert.truthy(package_alias_value_ident.symbol)

    assert.True(package_alias_value_ident.symbol:is_declared())
    assert.True(package_alias_value_ident.symbol:is_assigned())
    assert.True(package_alias_value_ident.symbol:is_referenced())

    assert.False(package_env_symbol:is_declared())
    assert.False(package_env_symbol:is_assigned())
    assert.False(package_env_symbol:is_referenced())

    assert.equal(export_inner_stat, export_type_symbol:get_canonical_declaration())
    assert.True(export_type_symbol:is_assigned())
    assert.True(export_type_symbol:is_referenced())

    assert.equal(export_inner_stat, export_value_symbol:get_canonical_declaration())
    assert.True(export_value_symbol:is_assigned())
    assert.True(export_value_symbol:is_referenced())
  end)

  it("should guard against re-declaration of the same export", function()
    local env = ProjectEnvironment.new()

    assert.False(pcall(function()
      -- file 'x'
      local tokens_x = Lexer.new("export x = 1; export x = 2"):tokenize()
      local result_x = Parser.new(tokens_x):parse()
      Binder.new(result_x, env, 'x'):bind()
    end))
  end)

  it("should guard against declaration of exports with returns", function()
    local env = ProjectEnvironment.new()

    assert.False(pcall(function()
      -- file 'x'
      local tokens_x = Lexer.new("export x = 1; return 2"):tokenize()
      local result_x = Parser.new(tokens_x):parse()
      Binder.new(result_x, env, 'x'):bind()
    end))
  end)

  it("should guard against declaration of exports with returns declaration", function()
    local env = ProjectEnvironment.new()

    assert.False(pcall(function()
      -- file 'x'
      local tokens_x = Lexer.new("export x = 1; declare returns number"):tokenize()
      local result_x = Parser.new(tokens_x):parse()
      Binder.new(result_x, env, 'x'):bind()
    end))
  end)

  it("should guard against re-declaration of returns across files", function()
    local env = ProjectEnvironment.new()

    assert.False(pcall(function()
      -- file 'x'
      local tokens_x = Lexer.new("return 'Hello, world!'"):tokenize()
      local result_x = Parser.new(tokens_x):parse()
      Binder.new(result_x, env, 'x'):bind()
  
      -- file 'y'
      local tokens_y = Lexer.new("declare package 'x' string"):tokenize()
      local result_y = Parser.new(tokens_y):parse()
      Binder.new(result_y, env, 'y'):bind()
    end))
  end)

  it("should guard against re-declaration of returns within files", function()
    local env = ProjectEnvironment.new()

    assert.False(pcall(function()
      -- file 'x'
      local tokens_x = Lexer.new("declare package 'x' string; return 'Hello, world!'"):tokenize()
      local result_x = Parser.new(tokens_x):parse()
      Binder.new(result_x, env, 'x'):bind()
    end))
  end)

  it("should guard against re-declaration of returns within files", function()
    local env = ProjectEnvironment.new()

    assert.False(pcall(function()
      -- file 'x'
      local tokens_x = Lexer.new("declare returns string; return 'Hello, world!'"):tokenize()
      local result_x = Parser.new(tokens_x):parse()
      Binder.new(result_x, env, 'x'):bind()
    end))
  end)
end)