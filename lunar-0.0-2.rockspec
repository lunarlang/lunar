---------------------------------------
-- AUTOGENERATED BY gen_rockspec.lua --
-- DO NOT EDIT DIRECTLY!             --
---------------------------------------

package = "Lunar"
version = "0.0-2"
source = {
  url = "git://github.com/lunarlang/lunar"
}
description = {
  summary = "Lunar, a superset programming language of Lua 5.1",
  homepage = "http://github.com/lunarlang/lunar",
  license = "Apache-2.0"
}
dependencies = {
  "lua >= 5.1, < 5.4",
  "luafilesystem >= 1.7, < 2.0"
}
build = {
  type = "builtin",
  copy_directories = { "./dist/lunar" },
  modules = {
    ["lunar.ast.stats.function_statement"] = "lunar/ast/stats/function_statement.lua",
    ["lunar.compiler.semantic.base_binder"] = "lunar/compiler/semantic/base_binder.lua",
    ["lunar.compiler.codegen.transpiler"] = "lunar/compiler/codegen/transpiler.lua",
    ["lunar.ast.stats.return_statement"] = "lunar/ast/stats/return_statement.lua",
    ["lunar.compiler.semantic.symbol"] = "lunar/compiler/semantic/symbol.lua",
    ["lunar.utils.diagnostic_utils"] = "lunar/utils/diagnostic_utils.lua",
    ["lunar.compiler.syntax.base_parser"] = "lunar/compiler/syntax/base_parser.lua",
    ["lunar.ast.decls.index_field_declaration"] = "lunar/ast/decls/index_field_declaration.lua",
    ["lunar.compiler.semantic.scope"] = "lunar/compiler/semantic/scope.lua",
    ["lunar.ast"] = "lunar/ast/init.lua",
    ["lunar.ast.stats.self_assignment_op_kind"] = "lunar/ast/stats/self_assignment_op_kind.lua",
    ["lunar.ast.decls.sequential_field_declaration"] = "lunar/ast/decls/sequential_field_declaration.lua",
    ["lunar.ast.syntax_kind"] = "lunar/ast/syntax_kind.lua",
    ["lunar.compiler.semantic.project_environment"] = "lunar/compiler/semantic/project_environment.lua",
    ["lunar.ast.decls.class_function_declaration"] = "lunar/ast/decls/class_function_declaration.lua",
    ["lunar.compiler.semantic.symbol_table"] = "lunar/compiler/semantic/symbol_table.lua",
    ["lunar.compiler.semantic.source_file_returns"] = "lunar/compiler/semantic/source_file_returns.lua",
    ["lunar.ast.exprs.binary_op_kind"] = "lunar/ast/exprs/binary_op_kind.lua",
    ["lunar.ast.exprs.identifier"] = "lunar/ast/exprs/identifier.lua",
    ["lunar.compiler.semantic.core_globals"] = "lunar/compiler/semantic/core_globals.lua",
    ["lunar.ast.decls.member_field_declaration"] = "lunar/ast/decls/member_field_declaration.lua",
    ["lunar.ast.stats.while_statement"] = "lunar/ast/stats/while_statement.lua",
    ["lunar.compiler.syntax.parser"] = "lunar/compiler/syntax/parser.lua",
    ["lunar.ast.exprs.lambda_expression"] = "lunar/ast/exprs/lambda_expression.lua",
    ["lunar.ast.stats.do_statement"] = "lunar/ast/stats/do_statement.lua",
    ["lunar.compiler.semantic.binder"] = "lunar/compiler/semantic/binder.lua",
    ["lunar.ast.decls.class_field_declaration"] = "lunar/ast/decls/class_field_declaration.lua",
    ["lunar.ast.exprs.member_expression"] = "lunar/ast/exprs/member_expression.lua",
    ["lunar.ast.exprs.nil_literal_expression"] = "lunar/ast/exprs/nil_literal_expression.lua",
    ["lunar.ast.exprs.string_literal_expression"] = "lunar/ast/exprs/string_literal_expression.lua",
    ["lunar.compiler.lexical.token_info"] = "lunar/compiler/lexical/token_info.lua",
    ["lunar.ast.stats.class_statement"] = "lunar/ast/stats/class_statement.lua",
    ["lunar.ast.exprs.table_literal_expression"] = "lunar/ast/exprs/table_literal_expression.lua",
    ["lunar.compiler.codegen.base_transpiler"] = "lunar/compiler/codegen/base_transpiler.lua",
    ["lunar.compiler.lexical.lexer"] = "lunar/compiler/lexical/lexer.lua",
    ["lunar.ast.exprs.number_literal_expression"] = "lunar/ast/exprs/number_literal_expression.lua",
    ["lunar.ast.exprs.type_assertion_expression"] = "lunar/ast/exprs/type_assertion_expression.lua",
    ["lunar.utils.string_utils"] = "lunar/utils/string_utils.lua",
    ["lunar.ast.stats.variable_statement"] = "lunar/ast/stats/variable_statement.lua",
    ["lunar.ast.syntax_node"] = "lunar/ast/syntax_node.lua",
    ["lunar.lunarc"] = "lunar/lunarc/init.lua",
    ["lunar.ast.stats.repeat_until_statement"] = "lunar/ast/stats/repeat_until_statement.lua",
    ["lunar.ast.exprs.boolean_literal_expression"] = "lunar/ast/exprs/boolean_literal_expression.lua",
    ["lunar.ast.stats.range_for_statement"] = "lunar/ast/stats/range_for_statement.lua",
    ["lunar.ast.stats.if_statement"] = "lunar/ast/stats/if_statement.lua",
    ["lunar.ast.stats.break_statement"] = "lunar/ast/stats/break_statement.lua",
    ["lunar.ast.decls.constructor_declaration"] = "lunar/ast/decls/constructor_declaration.lua",
    ["lunar.ast.exprs.argument_expression"] = "lunar/ast/exprs/argument_expression.lua",
    ["lunar.compiler.lexical.token_type"] = "lunar/compiler/lexical/token_type.lua",
    ["lunar.ast.exprs.function_call_expression"] = "lunar/ast/exprs/function_call_expression.lua",
    ["lunar.ast.stats.expression_statement"] = "lunar/ast/stats/expression_statement.lua",
    ["lunar.ast.stats.generic_for_statement"] = "lunar/ast/stats/generic_for_statement.lua",
    ["lunar.compiler.lexical.base_lexer"] = "lunar/compiler/lexical/base_lexer.lua",
    ["lunar.ast.stats.declaration_statement"] = "lunar/ast/stats/declaration_statement.lua",
    ["lunar.ast.exprs.variable_argument_expression"] = "lunar/ast/exprs/variable_argument_expression.lua",
    ["lunar.ast.decls.parameter_declaration"] = "lunar/ast/decls/parameter_declaration.lua",
    ["lunar.ast.exprs.prefix_expression"] = "lunar/ast/exprs/prefix_expression.lua",
    ["lunar.ast.exprs.unary_op_expression"] = "lunar/ast/exprs/unary_op_expression.lua",
    ["lunar.ast.exprs.index_expression"] = "lunar/ast/exprs/index_expression.lua",
    ["lunar.ast.exprs.unary_op_kind"] = "lunar/ast/exprs/unary_op_kind.lua",
    ["lunar.ast.exprs.function_expression"] = "lunar/ast/exprs/function_expression.lua",
    ["lunar.ast.exprs.binary_op_expression"] = "lunar/ast/exprs/binary_op_expression.lua",
    ["lunar.ast.stats.assignment_statement"] = "lunar/ast/stats/assignment_statement.lua",
  }
}
