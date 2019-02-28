local require_dev = require "spec.helpers.require_dev"

describe("Bindings of literal expressions", function()
  require_dev()

  it("should not add symbols to any ast containing only literal expressions and binary operations", function()
    local tokens = Lexer.new("local x = 1 and 2 + 3 == #{}"):tokenize()
    local result = Parser.new(tokens):parse()
    Binder.new(result):bind()

    local var_stat = result[1]
    
    local binop_expr = var_stat.exprlist[1]
    assert.same(AST.BinaryOpExpression.new(
      AST.NumberLiteralExpression.new(1),
      AST.BinaryOpKind.and_op,
      AST.BinaryOpExpression.new(
        AST.BinaryOpExpression.new(
          AST.NumberLiteralExpression.new(2),
          AST.BinaryOpKind.addition_op,
          AST.NumberLiteralExpression.new(3)
        ),
        AST.BinaryOpKind.equal_op,
        AST.UnaryOpExpression.new(
          AST.UnaryOpKind.length_op,
          AST.TableLiteralExpression.new({})
        )
      )
    ), binop_expr)
  end)

  it("should bind global identifier references nested in op expressions", function()
    local tokens = Lexer.new("local x = true and false or y"):tokenize()
    local result = Parser.new(tokens):parse()
    local env = Binder.new(result):bind()

    local var_stat = result[1]
    
    local expr_right_1 = var_stat.exprlist[1].right_operand
    local ref_ident_symbol = expr_right_1.symbol

    assert.truthy(ref_ident_symbol)
    assert.False(ref_ident_symbol.is_assigned)
    assert.falsy(ref_ident_symbol.declaration)
    assert.True(ref_ident_symbol.is_referenced)
    assert.equal(env.globals:get_value('y'), ref_ident_symbol)
  end)
  
end)