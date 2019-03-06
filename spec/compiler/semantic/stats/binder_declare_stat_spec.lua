local require_dev = require "spec.helpers.require_dev"

describe("Bindings of declared identifiers", function()
  require_dev()

  it("should declare global symbols with a separate assignment", function()
    local tokens = Lexer.new("declare global x; x = 2"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    local dec_ident = result[1].identifier
    local assign_ident = result[2].variables[1]

    assert.truthy(dec_ident.symbol)
    assert.truthy(assign_ident.symbol)
    assert.equal(dec_ident.symbol, assign_ident.symbol)
    assert.equal(result[1], dec_ident.symbol.declaration)
    assert.True(dec_ident.symbol.is_assigned)
    assert.False(dec_ident.symbol.is_referenced)

    assert.equal(dec_ident.symbol, env.globals:get_value('x'))
  end)
  
end)