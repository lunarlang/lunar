local require_dev = require "spec.helpers.require_dev"

describe("Bindings of core symbols", function()
  require_dev()

  it("should bind the core type symbols in local declarations", function()
    local type_map = {
      ["any"] = CoreGlobals:get_type("any") or false,
      ["unknown"] = CoreGlobals:get_type("unknown") or false,
      ["never"] = CoreGlobals:get_type("never") or false,
      ["nil"] = CoreGlobals:get_type("nil") or false,
      ["string"] = CoreGlobals:get_type("string") or false,
      ["boolean"] = CoreGlobals:get_type("boolean") or false,
      ["function"] = CoreGlobals:get_type("function") or false,
      ["userdata"] = CoreGlobals:get_type("userdata") or false,
      ["thread"] = CoreGlobals:get_type("thread") or false,
      ["table"] = CoreGlobals:get_type("table") or false,
    }

    for type_name, symbol in pairs(type_map) do
      local tokens = Lexer.new("local hello: " .. type_name):tokenize()
      local result = Parser.new(tokens):parse()
      local env = Binder.new(result):bind()

      env:link_external_references()
  
      local assignment = result[1]
      local identifier = assignment.identlist[1]
      
      assert.truthy(symbol, "CoreGlobals symbol does not exist with name '" .. type_name .. "'")
      assert.truthy(identifier.type_annotation)
      assert.truthy(identifier.type_annotation.symbol, "TypeAnnotation symbol does not exist with name '" .. type_name .. "'")
      assert.equal(symbol, identifier.type_annotation.symbol, "symbols are not equal for '" .. type_name .. "'")
      assert.False(symbol:is_declared())
      assert.False(symbol:is_assigned())
      assert.True(symbol:is_referenced())
      assert.True(symbol:is_builtin())
    end
  end)

  it("should bind non-existent core symbols as undeclared globals", function()
    local type_map = {
      ["frobulator"] = CoreGlobals:get_type("frobulator") or false,
    }

    for type_name, symbol in pairs(type_map) do
      local tokens = Lexer.new("local hello: " .. type_name):tokenize()
      local result = Parser.new(tokens):parse()
      local env = Binder.new(result):bind()
      
      env:link_external_references()
  
      local assignment = result[1]
      local identifier = assignment.identlist[1]
      
      assert.truthy(identifier.type_annotation)
      assert.False(identifier.type_annotation.symbol:is_declared())
      assert.False(identifier.type_annotation.symbol:is_assigned())
      assert.True(identifier.type_annotation.symbol:is_referenced())
      assert.False(identifier.type_annotation.symbol:is_builtin())
      assert.is_not.equal(symbol, identifier.type_annotation.symbol)
    end
  end)
end)
